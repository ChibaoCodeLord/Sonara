import { createHash } from 'node:crypto';

export const cleanName=value=>String(value||'').normalize('NFC').trim().replace(/\s+/g,' ');
export const nameKey=value=>cleanName(value).normalize('NFD').replace(/\p{M}/gu,'').replace(/đ/gi,'d').toLowerCase().replace(/[^\p{L}\p{N}]+/gu,' ').trim();
const canonicalNames=['Sơn Tùng M-TP','Mỹ Tâm','Hoàng Thùy Linh','Đen Vâu','HIEUTHUHAI','Vũ','Hà Anh Tuấn','Phan Mạnh Quỳnh','Hòa Minzy','Văn Mai Hương','Bùi Trường Linh','Da LAB','Ngọt','Chillies','Vũ Cát Tường','Trúc Nhân','Tóc Tiên','Noo Phước Thịnh','Đức Phúc','ERIK','SOOBIN','Binz','MONO','MIN','Kai Đinh','Kimmese','JustaTee','LyLy','DTAP','Bùi Anh Tuấn','Gemini Hùng Huỳnh','Juky San','Thắng','Red Hot Chili Peppers','Ninh Dương Lan Ngọc','Minh Hằng','Hồ Ngọc Hà','Muộii','INNA','W/n','Ngọc Trâm','Eric Nam 에릭남'];
const aliases=new Map(canonicalNames.map(n=>[nameKey(n),n]));
for(const [alias,name]of Object.entries({'Đen':'Đen Vâu','Hoàng Thuỳ Linh':'Hoàng Thùy Linh','buitruonglinh':'Bùi Trường Linh','Binz Da Poet':'Binz','JustaTeeMusic':'JustaTee','Soobin Hoàng Sơn':'SOOBIN',"Ho Ngoc Ha's":"Hồ Ngọc Hà"}))aliases.set(nameKey(alias),name);
export const canonicalName=value=>aliases.get(nameKey(value))||cleanName(value);
export function channelArtist(channel){
  const name=cleanName(channel).replace(/\s+(?:official(?:\s+channel)?|channel)$/i,'').trim();
  return aliases.get(nameKey(name))||null;
}
export const artistSourceKey=name=>`youtube:artist:${createHash('sha256').update(nameKey(name)).digest('hex')}`;
export function resolveYouTubeCredits(metadata={},overrides={}){
  let names,kind;
  if(overrides[metadata.id]){names=overrides[metadata.id];kind='reviewed_title_credit';}
  else if(cleanName(metadata.artist)){names=String(metadata.artist).split(/\s*,\s*/);kind='source_artist';}
  else if(channelArtist(metadata.channel||metadata.uploader)){names=[channelArtist(metadata.channel||metadata.uploader)];kind='channel_artist';}
  else return null;
  names=[...new Set(names.map(canonicalName).filter(Boolean))];
  return {kind,names,artists:names.map((name,index)=>({id:artistSourceKey(name).slice('youtube:'.length),name,image_url:'',role:index?'featured_artist':'main_artist'})),evidence:{video_id:metadata.id,title:metadata.title||'',channel:metadata.channel||metadata.uploader||'',artist:metadata.artist||''}};
}
export function explicitAlbum(metadata={}){
  if(cleanName(metadata.album))return {title:cleanName(metadata.album),kind:'source_album'};
  const title=cleanName(metadata.title);
  const quoted=title.match(/(?:Album\s*['“"]([^'”"]+)['”"]|['“"]([^'”"]+)['”"]\s*Album)/iu);
  if(quoted)return {title:cleanName(quoted[1]||quoted[2]),kind:'title_album'};
  const plain=title.match(/\|\s*([^|'"]+?)\s+Album(?:\s*\(|\s*$)/iu);
  if(plain)return {title:cleanName(plain[1]),kind:'title_album'};
  const numbered=title.match(/\(Album\s+([^()]+?)\s*-\s*Track\b/iu);
  if(numbered)return {title:cleanName(numbered[1]),kind:'title_album'};
  const ep=title.match(/\bEP\s+([^)|]+)(?=\)|\||$)/iu);
  if(ep)return {title:cleanName(ep[1]),kind:'title_ep',album_type:'ep'};
  return null;
}
export function matchAlbum(candidates,albumTitle,artistName){
  // Full title and artist must agree. A video's upload date is never a release date.
  const trimSuffix=s=>nameKey(s).replace(/ (single|ep)$/,'');
  const hits=candidates.filter(c=>trimSuffix(c.collectionName)===trimSuffix(albumTitle)&&nameKey(canonicalName(c.artistName))===nameKey(canonicalName(artistName)));
  const unique=new Map(hits.map(c=>[c.collectionId,c]));return unique.size===1?[...unique.values()][0]:null;
}
