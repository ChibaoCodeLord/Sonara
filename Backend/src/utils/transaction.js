import mongoose from 'mongoose';
import {ApiError} from './apiError.js';
export async function transaction(work){
  const session=await mongoose.startSession();
  try{for(let attempt=0;attempt<3;attempt++){try{let result;await session.withTransaction(async()=>{result=await work(session);});return result;}catch(error){if(error.code!==11000)throw error;}}throw new ApiError(409,'Dữ liệu vừa thay đổi, hãy tải lại và thử lại.');}
  finally{await session.endSession();}
}
