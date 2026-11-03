let access=null,sessionUser=null,refreshFlight=null;
const listeners=new Set();
const publish=(token,user)=>{access=token;sessionUser=user;for(const listener of listeners)listener(user);};
export const subscribe=listener=>{listeners.add(listener);return()=>listeners.delete(listener);};
export const currentUser=()=>sessionUser;
export const updateSessionUser=user=>publish(access,user);
export class AdminError extends Error{constructor(message,status){super(message);this.status=status;}}
async function decode(response){let json;try{json=await response.json();}catch{throw new AdminError('Máy chủ trả về dữ liệu không hợp lệ.',response.status);}if(!response.ok)throw new AdminError(json.message||json.error||'Không hoàn thành được yêu cầu.',response.status);return json.data;}
async function session(path,body){return decode(await fetch('/api/v1/admin/session'+path,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json','X-Sonara-Admin':'website'},body:JSON.stringify(body||{})}));}
export async function login(email,password){const data=await session('',{email,password,device_name:'Sonara Admin Web'});publish(data.token,data.user);return data.user;}
export function refresh(){
  if(!refreshFlight){const work=async()=>{try{const data=await session('/refresh');publish(data.token,data.user);return data.user;}catch(e){publish(null,null);throw e;}};
    refreshFlight=(globalThis.navigator?.locks?navigator.locks.request('sonara-admin-refresh',work):work()).finally(()=>{refreshFlight=null;});}
  return refreshFlight;
}
export async function logout(){try{await session('/logout');}finally{publish(null,null);}}
export async function api(path,options={},retry=true){
  const {body,...rest}=options,isForm=body instanceof FormData;
  const response=await fetch('/api/v1'+path,{...rest,credentials:'same-origin',headers:{...(body&&!isForm?{'Content-Type':'application/json'}:{}),...(access?{Authorization:'Bearer '+access}:{}),...options.headers},body:body===undefined?undefined:isForm?body:JSON.stringify(body)});
  if(response.status===401&&retry){await refresh();return api(path,options,false);}return decode(response);
}
export function upload(path,form,onProgress,signal){return new Promise((resolve,reject)=>{
  const xhr=new XMLHttpRequest();xhr.open('POST','/api/v1'+path);xhr.withCredentials=true;if(access)xhr.setRequestHeader('Authorization','Bearer '+access);
  xhr.upload.onprogress=e=>{if(e.lengthComputable)onProgress(Math.round(e.loaded/e.total*100));};
  xhr.onload=()=>{let json;try{json=JSON.parse(xhr.responseText);}catch{return reject(new AdminError('Phản hồi upload không hợp lệ.',xhr.status));}if(xhr.status>=200&&xhr.status<300)resolve(json.data);else reject(new AdminError(json.message||'Upload không thành công.',xhr.status));};
  xhr.onerror=()=>reject(new AdminError('Mất kết nối. Hãy kiểm tra danh sách trước khi thử lại để tránh upload trùng.',0));xhr.onabort=()=>reject(new AdminError('Đã hủy gửi file.',0));
  if(signal){if(signal.aborted){reject(new AdminError('Đã hủy gửi file.',0));return;}signal.addEventListener('abort',()=>xhr.abort(),{once:true});}xhr.send(form);
});}
