import { Track } from './track.model.js';

// Export Song đồng nhất với Track để đảm bảo các controller và service cũ vẫn hoạt động trơn tru
export const Song = Track;
export default Track;
