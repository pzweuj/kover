import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/database/app_database.dart';
import 'package:kover/mapping/dto/progress_dto_mappings.dart';
import 'package:kover/mapping/tables/reading_progress_data.dart';
import 'package:kover/utils/exceptions.dart';

class ReaderSyncOperations {
  final Openapi _client;

  const ReaderSyncOperations({required this._client});

  /// Fetch continue point for [seriesId]
  Future<int> getContinuePoint(int seriesId) async {
    final res = await _client.apiReaderContinuePointGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw SyncException(
        'Failed to load continue point',
        statusCode: res.statusCode,
      );
    }

    final chapterDto = res.body!;
    return chapterDto.id ?? 0;
  }

  /// Fetch progress for [chapterId]
  Future<ReadingProgressCompanion> getProgress(int chapterId) async {
    final res = await _client.apiReaderGetProgressGet(chapterId: chapterId);
    if (!res.isSuccessful || res.body == null) {
      throw SyncException(
        'Failed to load progress',
        statusCode: res.statusCode,
      );
    }
    final dto = res.body!;
    return dto.toReadingProgressCompanion();
  }

  /// Post local [ReadingProgressData]
  Future<void> sendProgress(ReadingProgressData progress) async {
    final res =
        await _client.apiReaderProgressPost(body: progress.toProgressDto());
    if (!res.isSuccessful) {
      throw SyncException(
        'Failed to send progress',
        statusCode: res.statusCode,
      );
    }
  }

  /// Mark entire series as read, without generating a reading session
  Future<void> markSeriesRead(int seriesId) async {
    final res = await _client.apiReaderMarkReadPost(
      body: MarkReadDto(seriesId: seriesId, generateReadingSession: false),
    );
    if (!res.isSuccessful) {
      throw SyncException(
        'Failed to mark series as read',
        statusCode: res.statusCode,
      );
    }
  }

  /// Mark entire series as unread, without generating a reading session
  Future<void> markSeriesUnread(int seriesId) async {
    final res = await _client.apiReaderMarkUnreadPost(
      body: MarkReadDto(seriesId: seriesId, generateReadingSession: false),
    );
    if (!res.isSuccessful) {
      throw SyncException(
        'Failed to mark series as unread',
        statusCode: res.statusCode,
      );
    }
  }

  /// Mark entire volume as read, without generating a reading session
  Future<void> markVolumeRead({
    required int seriesId,
    required int volumeId,
  }) async {
    final res = await _client.apiReaderMarkVolumeReadPost(
      body: MarkVolumeReadDto(
        seriesId: seriesId,
        volumeId: volumeId,
        generateReadingSession: false,
      ),
    );
    if (!res.isSuccessful) {
      throw SyncException(
        'Failed to mark volume as read',
        statusCode: res.statusCode,
      );
    }
  }

  /// Mark entire volume as unread, without generating a reading session
  Future<void> markVolumeUnread({
    required int seriesId,
    required int volumeId,
  }) async {
    final res = await _client.apiReaderMarkVolumeUnreadPost(
      body: MarkVolumeReadDto(
        seriesId: seriesId,
        volumeId: volumeId,
        generateReadingSession: false,
      ),
    );
    if (!res.isSuccessful) {
      throw SyncException(
        'Failed to mark volume as unread',
        statusCode: res.statusCode,
      );
    }
  }
}
