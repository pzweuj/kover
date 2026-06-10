import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('zh')];
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Locale localeFromCode(String code) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => const Locale('en'),
    );
  }

  bool get isZh => locale.languageCode == 'zh';

  String _t(String en, String zh) => isZh ? zh : en;

  String get appTitle => 'Kover';
  String get english => 'English';
  String get chinese => '中文';
  String get language => _t('Language', '语言');
  String get general => _t('General', '通用');
  String get themeMode => _t('Theme Mode', '主题模式');
  String get system => _t('System', '跟随系统');
  String get light => _t('Light', '浅色');
  String get dark => _t('Dark', '深色');
  String get outlinedTheme => _t('Outlined Theme', '描边主题');
  String get settings => _t('Settings', '设置');
  String get credentials => _t('Credentials', '凭据');
  String get baseUrl => _t('Base URL', '服务器地址');
  String get primaryBaseUrl => _t('Primary Base URL', '主 URL（内网）');
  String get fallbackBaseUrl => _t('Fallback Base URL', '备用 URL（外网）');
  String get fallbackBaseUrlDescription => _t(
    'Optional. Used automatically when the primary URL is unreachable.',
    '可选。当主 URL 无法访问时自动回退使用。',
  );
  String get apiKey => _t('API Key', 'API 密钥');
  String get save => _t('Save', '保存');
  String get dataManagement => _t('Data Management', '数据管理');
  String get downloadAllCovers => _t('Download All Covers', '下载全部封面');
  String get downloadAllCoversDescription => _t('If disabled, covers will only be downloaded together with chapters. Covers will still be fetched from the server on demand when not downloaded and a connection is available.', '关闭后，封面只会随章节一起下载。未下载封面且网络可用时，仍会按需从服务器获取。');
  String get maxConcurrentDownloads => _t('Max Concurrent Downloads', '最大并发下载数');
  String get reclaimSpace => _t('Reclaim Space', '回收空间');
  String get clearDownloads => _t('Clear Downloads', '清除下载');
  String get clearCovers => _t('Clear Covers', '清除封面');
  String get clearDatabase => _t('Clear Database', '清空数据库');
  String get areYouSure => _t('Are you sure?', '确定吗？');
  String get clearDatabaseDescription => _t('This will clear the entire local database, including any unsynced progress and downloaded data. This action cannot be undone.', '这将清空整个本地数据库，包括所有未同步进度和已下载数据。此操作无法撤销。');
  String get cancel => _t('Cancel', '取消');
  String get databaseBusy => _t('Database busy...', '数据库忙碌中...');
  String get databaseSize => _t('Database Size: ', '数据库大小：');
  String get anonymousDiagnostics => _t('Send anonymous crash reports and diagnostics', '发送匿名崩溃报告和诊断信息');
  String get anonymousDiagnosticsQuestion => _t('Send anonymous crash reports and diagnostics?', '发送匿名崩溃报告和诊断信息？');
  String get anonymousDiagnosticsDescription => _t('Help improve the app by sending anonymous error and performance statistics. The data does not contain any personal information and is uniquely used to improve the app.', '发送匿名错误和性能统计信息，帮助改进应用。这些数据不包含任何个人信息，仅用于改进应用。');
  String get diagnosticsCanChange => _t('This can be changed in the settings at any time.', '你可以随时在设置中更改。');
  String get noThanks => _t('No, thanks', '不用了，谢谢');
  String get imIn => _t('I\\\'m in!', '我同意');
  String get home => _t('Home', '首页');
  String get wantToRead => _t('Want to Read', '想读');
  String get menu => _t('Menu', '菜单');
  String get allSeries => _t('All Series', '全部系列');
  String get collections => _t('Collections', '合集');
  String get readingLists => _t('Reading Lists', '阅读列表');
  String get libraries => _t('Libraries', '书库');
  String get more => _t('More', '更多');
  String get downloadQueue => _t('Download Queue', '下载队列');
  String get onDeck => _t('On Deck', '接着读');
  String get recentlyUpdated => _t('Recently Updated', '最近更新');
  String get recentlyAdded => _t('Recently Added', '最近添加');
  String get showAll => _t('Show All', '显示全部');
  String get showLess => _t('Show Less', '收起');
  String get showMore => _t('Show More', '显示更多');
  String get summary => _t('Summary', '简介');
  String get genres => _t('Genres', '类型');
  String get writers => _t('Writers', '作者');
  String get sortBy => _t('Sort by', '排序方式');
  String get name => _t('Name', '名称');
  String get dateAdded => _t('Date Added', '添加日期');
  String get lastModified => _t('Last Modified', '最后修改');
  String get direction => _t('Direction', '方向');
  String get sortDirection => _t('Sort Direction', '排序方向');
  String get ascending => _t('Ascending', '升序');
  String get descending => _t('Descending', '降序');
  String get filter => _t('Filter', '筛选');
  String get hideRead => _t('Hide Read', '隐藏已读');
  String get series => _t('Series', '系列');
  String get volumes => _t('Volumes', '卷');
  String get chapters => _t('Chapters', '章节');
  String get storyline => _t('Storyline', '主线');
  String get specials => _t('Specials', '特别篇');
  String get download => _t('Download', '下载');
  String get removeDownload => _t('Remove Download', '移除下载');
  String get cancelAll => _t('Cancel All', '全部取消');
  String get noDownloadsInQueue => _t('No downloads in queue', '下载队列为空');
  String get addToWantToRead => _t('Add to Want to Read', '添加到想读');
  String get removeFromWantToRead => _t('Remove from Want to Read', '从想读中移除');
  String get markRead => _t('Mark Read', '标为已读');
  String get markUnread => _t('Mark Unread', '标为未读');
  String get refreshMetadata => _t('Refresh Metadata', '刷新元数据');
  String get refreshCovers => _t('Refresh Covers', '刷新封面');
  String get read => _t('Read', '阅读');
  String get continueReading => _t('Continue Reading', '继续阅读');
  String get readerSettings => _t('Reader Settings', '阅读器设置');
  String get readingDirection => _t('Reading Direction', '阅读方向');
  String get leftToRight => _t('Left To Right', '从左到右');
  String get rightToLeft => _t('Right To Left', '从右到左');
  String get readerMode => _t('Reader Mode', '阅读模式');
  String get imageFit => _t('Image Fit', '图片适配');
  String get originalSize => _t('Original', '原始大小');
  String get horizontal => _t('Horizontal', '横向');
  String get vertical => _t('Vertical', '纵向');
  String get twoPage => _t('Two Page', '双页');
  String get fitDirection => _t('Fit Direction', '适配方向');
  String get contain => _t('Contain', '完整显示');
  String get stretch => _t('Stretch', '拉伸填充');
  String get width => _t('Width', '宽度');
  String get height => _t('Height', '高度');
  String get margins => _t('Margins', '边距');
  String get verticalGap => _t('Vertical Gap', '纵向间距');
  String get pageGap => _t('Page Gap', '页面间距');
  String get coverPage => _t('Cover Page', '封面页');
  String get coverPageDescription => _t('Treat the first page as the cover, showing it as a single page', '将第一页视为封面，并以单页显示');
  String get ignoreSafeAreas => _t('Ignore Safe Areas', '忽略安全区域');
  String get showProgressBar => _t('Show Progress Bar', '显示进度条');
  String get setDefaults => _t('Set Defaults', '设为默认');
  String get reset => _t('Reset', '重置');
  String get fontSize => _t('Font Size', '字体大小');
  String get lineHeight => _t('Line Height', '行高');
  String get wordSpacing => _t('Word Spacing', '词间距');
  String get letterSpacing => _t('Letter Spacing', '字间距');
  String get highlightResumeParagraph => _t('Highlight Resume Paragraph', '高亮续读段落');
  String get tableOfContents => _t('Table of Contents', '目录');
  String get dismiss => _t('Dismiss', '忽略');
  String get go => _t('Go', '前往');
  String get back => _t('Back', '返回');
  String get noActiveSyncOperations => _t('No active sync operations', '没有正在进行的同步操作');
  String get syncingAllSeries => _t('Syncing all series', '正在同步全部系列');
  String get syncingMetadata => _t('Syncing metadata', '正在同步元数据');
  String get syncingRecentlyAdded => _t('Syncing recently added', '正在同步最近添加');
  String get syncingRecentlyUpdated => _t('Syncing recently updated', '正在同步最近更新');
  String get syncingLibraries => _t('Syncing libraries', '正在同步书库');
  String get syncingProgress => _t('Syncing progress', '正在同步进度');
  String get syncingCovers => _t('Syncing covers', '正在同步封面');
  String get syncingCollections => _t('Syncing collections', '正在同步合集');
  String get syncingReadingLists => _t('Syncing reading lists', '正在同步阅读列表');
  String get refreshingServerSettings => _t('Refreshing server settings', '正在刷新服务器设置');
  String get notSignedIn => _t('Not Signed In', '未登录');
  String get noCredentialsConfigured => _t('No credentials configured. Please add your server URL and API key in Settings.', '尚未配置凭据。请在设置中添加服务器地址和 API 密钥。');
  String get openSettings => _t('Open Settings', '打开设置');
  String get connectionError => _t('Connection Error', '连接错误');
  String get failedToFetchUser => _t('Failed to fetch user. Please check your credentials or try again.', '获取用户信息失败。请检查凭据或重试。');
  String get retry => _t('Retry', '重试');
  String get goToChapter => _t('Go to chapter', '前往章节');
  String get goToSeries => _t('Go to series', '前往系列');
  String get github => _t('GitHub: ', 'GitHub：');
  String get madeWithLove => _t('Made with ❤️', '用 ❤️ 制作');
  String countLabel(String label, int count) => '$label ($count)';
  String itemCount(int count) => isZh ? '$count 项' : '$count ${count == 1 ? "item" : "items"}';
  String moreCount(int count) => isZh ? '+$count 更多' : '+$count more';
  String previousChapter(String? title) => isZh ? '上一章：${title ?? ""}' : 'Previous: ${title ?? ""}';
  String nextChapter(String? title) => isZh ? '下一章：${title ?? ""}' : 'Next: ${title ?? ""}';
  String unsupportedFormat(Object format) => _t('Unsupported format: $format', '不支持的格式：$format');
  String refreshingMetadataForSeries(int seriesId) => _t('Refreshing metadata for series $seriesId', '正在刷新系列 $seriesId 的元数据');
  String refreshingCoversForSeries(int seriesId) => _t('Refreshing covers for series $seriesId', '正在刷新系列 $seriesId 的封面');
  String version(String version, String buildNumber) => _t('Version: $version ($buildNumber)', '版本：$version ($buildNumber)');
  String wordCount(String count) => isZh ? '$count 字' : '$count words';
  String remainingHours(String hours) => isZh ? '约 $hours 小时' : '~$hours hours';
  String pages(String count) => isZh ? '$count 页' : '$count pages';
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
