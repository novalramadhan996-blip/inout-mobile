$content = Get-Content 'D:\flutter_pub_cache\hosted\pub.dev\flutter_app_badger-1.5.0\android\build.gradle' -Raw
$content = $content -replace 'namespace "fr.g123k.flutterappbadge"', 'namespace "fr.g123k.flutterappbadge.flutterappbadger"'
Set-Content -Path 'D:\flutter_pub_cache\hosted\pub.dev\flutter_app_badger-1.5.0\android\build.gradle' -Value $content
