import '../models/following_artist_model.dart';
import '../models/library_playlist_model.dart';
import '../models/recent_hum_history_model.dart';

class LibraryMockService {
  List<FollowingArtistModel> getFollowingArtists() {
    return const [
      FollowingArtistModel(
        id: 'artist_vu',
        name: 'Vũ.',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBmSySYh-7dEMQO-_CTuFf85BI73GXvpoXIkaOMIXFjMLPUlRV1I4IRilHaOEMi_XRmYcF9CtYXtvtVzbw7hTYEdfkhhRLHd2bmr7f6VLaqpjA04obriCPT70HLzaAY8Wtng6tW0egAkn45MVlED1lLHiRiZWhl_qRhc3et_MyjdL9hFZbSzUscDOIQ0IVKAMWu6mlda6AZLguwVJ4I0x4PmwDugcZFComve0krcX_kLtDBZsQqNyugsw',
        isVerified: true,
      ),
      FollowingArtistModel(
        id: 'artist_dalab',
        name: 'Da LAB',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCJNICFCuWLUBJPZGCJgRKSOjMYhPhFpJK_6RDrDj5A2IambHydFwECHHhZl-upjKlD4v-NK8t8aTEwAcfWspkSHUzLcKYiZLJ5yyj4gizQWeatUS_FhzIIXpq1bY-cou9xoOrAJKHAfueZmIz7Ma3-hH4jm-eni-3jSuh0KkRTRDoZQxCrczXKN55VbrsYQ0O8O-SZeQm522y7MBiSFbdTs4GwIM4eU-8Hrg4hdHJ6ja3nuWnLY2YiFA',
        hasNewUpdate: true,
      ),
      FollowingArtistModel(
        id: 'artist_miule',
        name: 'Miu Lê',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCcwmGZ3SVcJjbkIdQztrmzdmUm0rCR6cL9ZsG5BaZ84ptCZLQqM325co-Mak-E1nKkCnc-x8SATGQGlPIv8SJZGnmUGh_Dnxz8m6herF1A67w7opgAjRDzo5qYVHQxEAATBU213ox9yuhscX6vugHfrECpUhRsvyGqwUBYHPRqrwVxLC0eoUAUQxoPU7FRpWRGSMI-vDnVWyC8MwgcflmUbcBzFiUfZuC-GVz6f9lpqW8CeYeLbYtxqg',
        hasNewUpdate: true,
      ),
      FollowingArtistModel(
        id: 'artist_hoangdung',
        name: 'Hoàng Dũng',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAJKh-36hn7nNqXnB91tJ5L0grbnGWI43OiQCOCj4lG7OB-1qg5ZCuoXbhoP0_HuIpSgw8meOBKizd3zAPD_btHtZYOPzMrQYCS4n0y4RfxRV00Vt8pXHFOYh81MUQkPwfuNjh-m2FPJfHF1ORAe6lMg-YO5n9d_eoxMfojvnLH4wHiQeV4Pd1YjEcMbrUJ74fptQvooJmhHmvlfAER8svAicLuIFhLEYv_WzfLFi5jtHVwX6TY05EZ_Q',
      ),
      FollowingArtistModel(
        id: 'artist_sontung',
        name: 'Sơn Tùng M-TP',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCAlZZr1_y6z-95OiAi_psbG8a489FD3OmbTnmD0MYCBw9CnR0GKC6e_wQdijHX8BfAZEZPhogXXwCEYNkABgTgwXGv16-esuyytPmd061zWSFXBVItsS8pKu1zx3naQBl7ax5uoQBOV8V8oH4_xFi46TUK57r9Si44nrEAUXSL3UDDRGzDkQ_I7klW-pr8lUC3Y4bajBYSBkNUgFoQV-P9Ha_l4DP5ZsC1DuiJvZx-z1ws8WJgpM6kaQ',
      ),
    ];
  }

  List<LibraryPlaylistModel> getPlaylists() {
    return const [
      LibraryPlaylistModel(
        id: 'playlist_lofi_chill',
        title: 'Đêm Mưa & Lo-Fi Chill',
        creator: 'Sonara AI Mood',
        trackCount: 42,
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAEdWZlzyvtMzooqvM1KU_NOYjKE0X-fDFAEm2O4iX5gmh5uHHrLCAXRSd4fDWUKqE4o-EKVbw5-05saRA-mq8vtTHJFyj-CRAUgKPUetrqhhNnPLJclsyTdS2O9Xu6dMkXewtID00XBX-dMApXRl1o20oXGoF5X5VP3dh6k8oulFwqlTS9d2hgXp8GVDfaLjmxYC4ZfUaCmJLl2qOVcYeJM5o8yW1PkWifyqdZXIChuyTeseviy0nPag',
        badgeType: 'ai_mood',
        badgeLabel: 'AI Mood',
      ),
      LibraryPlaylistModel(
        id: 'playlist_workout_135',
        title: 'Workout Energy Boost 135 BPM',
        creator: 'Phối tự động',
        trackCount: 28,
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAGcT1HSKPmMjPNvVjucM-mnHK3mGVVOc_PxBNQY2lKAebs88eaMkyyJ3cmbCc0Siw1L4AVnwULP-9FPL-_tRgeeiIac96vykeawaoaQCemN5p2TbIZ7MtCaQxvOs-W4s6pjUfLLa6SZcRMYT3Ih-fSxzIhIgYtt9AFcJbsrn4mEkrUmtnhBgPHvxiX3cdEnjH5v-dByk4FVdViiX-W3axZcEAfOP0rMntzpguC5tcM1c3NWEobaqSNVg',
        badgeType: 'auto_mix',
        badgeLabel: 'Auto Mix',
      ),
      LibraryPlaylistModel(
        id: 'playlist_vpop_indie',
        title: 'V-Pop Indie Giai Điệu Buồn',
        creator: 'Tự tạo bởi bạn',
        trackCount: 65,
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAozNtjW9wfap4bZfH0a4OkeNx0eJHdoT2o3ux81VMx5SmKX0rDkXCi5Q6hmdSuHg0bl9QMnIxtVkP5g3x8XYaSMhygo3oBJsM8MIL_9UCul_TQ-lzjkvcbLZENTKmaJDme1Q82I1x56rUSEHC9-N71N1WopVOOtBoJ6zFEZUNaiwQjXvJPTpl9vfqw2_D9P1daNMDqwcA_-b19MsNF7FtI2I9PmusvgTHeVLLs0G0r7jn8-EZugWHD-Q',
        badgeType: 'user_created',
        badgeLabel: 'Cá nhân',
      ),
    ];
  }

  RecentHumHistoryModel getRecentHumMatch() {
    return const RecentHumHistoryModel(
      id: 'hum_match_1',
      title: 'Từng Quen',
      artist: 'W/n, ft. Vũ.',
      matchPercentage: '98%',
      timeAgo: '2 giờ trước',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDqO2pyuw7YOXhJ8pHIeg6ea8eVLqg9mneAUM5hRLoBzoHTc-wLcSYoR4q3V1xvMc2Wpd0ye9UzGETebpGd8Wd4xi8jx9I-E0Sy0lDV2TevgmTcPNx7tDC23dHyRo0p-JlLwd4mx11483FXrZLXv7Ie4ewbc8Jux4K0Sb4HVmkrWXs26IIXa5lGrRt4cw8_oj2pDmYD_9idVaqx5K1J4wtBqVWdTydBXxa_kNlPS_wckTDGz_nagoSNtw',
    );
  }
}
