# Offline Music Player

**Sinh viên:** Nguyễn Thanh Liêm  
**MSSV:** 2224802010267  
**Môn học:** Thực hành Đồ họa và Nhập môn Tương tác  
**Giảng viên:** Cô Nguyễn Thị Hồng  
**Ngày hoàn thành:** 16/05/2026

---

## Giới thiệu

Offline Music Player là ứng dụng nghe nhạc không cần kết nối mạng, được xây dựng bằng Flutter. Ứng dụng cho phép người dùng quét và phát các file nhạc có sẵn trên thiết bị Android, tạo playlist, tìm kiếm bài hát và hiển thị lời bài hát (LRC).

## Tính năng chính

- Quét và phát nhạc từ bộ nhớ thiết bị
- Play/Pause, Next/Previous, Seek
- Shuffle và Repeat (Off/All/One)
- Tạo, xóa, đổi tên playlist
- Thêm/xóa bài hát vào playlist
- Tìm kiếm động (search as you type)
- Hiển thị lời bài hát (hỗ trợ file .lrc)
- Điều chỉnh âm lượng và tốc độ phát
- Giao diện tối (dark theme)
- Phát nhạc nền (background playback)

## Công nghệ sử dụng

- **Flutter** - Framework đa nền tảng
- **just_audio** - Phát audio
- **audio_service** - Phát nhạc nền
- **provider** - Quản lý state
- **shared_preferences** - Lưu trữ dữ liệu
- **on_audio_query** - Quét nhạc từ thiết bị
- **permission_handler** - Quản lý quyền truy cập

## Cấu trúc thư mục

```
lib/
├── main.dart
├── models/
│   ├── song_model.dart
│   ├── playlist_model.dart
│   └── playback_state_model.dart
├── services/
│   ├── audio_player_service.dart
│   ├── storage_service.dart
│   ├── permission_service.dart
│   ├── playlist_service.dart
│   ├── lyrics_service.dart
│   └── sample_song_service.dart
├── providers/
│   ├── audio_provider.dart
│   ├── playlist_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── now_playing_screen.dart
│   ├── playlist_screen.dart
│   ├── all_songs_screen.dart
│   ├── search_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── song_tile.dart
│   ├── mini_player.dart
│   ├── player_controls.dart
│   ├── progress_bar.dart
│   ├── playlist_card.dart
│   └── album_art.dart
└── utils/
    ├── constants.dart
    ├── duration_formatter.dart
    └── color_extractor.dart
```

## Hướng dẫn chạy

1. Cài đặt Flutter SDK (phiên bản 3.10.4 trở lên)
2. Clone repo: `git clone <url>`
3. Di chuyển vào thư mục: `cd offline_music_player`
4. Cài dependencies: `flutter pub get`
5. Chạy ứng dụng: `flutter run`

## Hướng dẫn sử dụng LRC Lyrics

Để hiển thị lời bài hát đồng bộ, đặt file `.lrc` cùng tên với file nhạc trong cùng thư mục.

Ví dụ:
```
/storage/Music/BaiHat.mp3
/storage/Music/BaiHat.lrc
```

Định dạng LRC:
```
[00:12.00]Lời bài hát dòng 1
[00:17.50]Lời bài hát dòng 2
```

## Video giới thiệu

Link video: _(chèn link Google Drive sau khi quay và upload)_

