# 国际化 (l10n) 使用指南

## 概述

本项目使用 Flutter 官方的 `intl` 包和 ARB (Application Resource Bundle) 文件来管理多语言支持。

## 文件结构

```
lib/l10n/
  ├── app_en.arb          # 英文翻译（模板文件）
  ├── app_ja.arb          # 日文翻译
  └── app_zh.arb          # 中文翻译

l10n.yaml                  # l10n 配置文件
```

## 添加新的翻译字符串

### 1. 编辑 ARB 文件

在 `lib/l10n/app_en.arb` 中添加新的键值对（这是模板文件）：

```json
{
  "@@locale": "en",
  "newKey": "New text in English",
  "@newKey": {
    "description": "Description of what this text is used for"
  }
}
```

### 2. 在其他语言文件中添加对应翻译

在 `app_ja.arb` 和 `app_zh.arb` 中添加相同的键，但使用对应的翻译：

**app_ja.arb:**
```json
{
  "@@locale": "ja",
  "newKey": "日本語のテキスト"
}
```

**app_zh.arb:**
```json
{
  "@@locale": "zh",
  "newKey": "中文文本"
}
```

### 3. 生成本地化文件

运行以下命令生成 Dart 代码：

```bash
flutter gen-l10n
```

生成的文件将位于 `.dart_tool/flutter_gen/gen_l10n/` 目录中。

### 4. 在代码中使用

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 在 Widget 的 build 方法中
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Text(l10n.newKey);
}
```

## 支持的语言

目前支持以下语言：
- 英语 (en)
- 日语 (ja)
- 中文 (zh)

## 配置说明

`l10n.yaml` 文件包含 l10n 生成器的配置：

```yaml
arb-dir: lib/l10n                      # ARB 文件所在目录
template-arb-file: app_en.arb          # 模板文件（英文）
output-localization-file: app_localizations.dart  # 输出文件名
```

## 最佳实践

1. **始终在模板文件中添加描述**：在 `@key` 元数据中添加 `description` 字段，说明文本的用途。

2. **保持键名一致**：在所有语言的 ARB 文件中使用相同的键名。

3. **使用有意义的键名**：使用驼峰命名法，键名应该描述文本的用途，而不是内容。
   - ✅ 好: `tipFromEma`, `aboutTitle`
   - ❌ 差: `text1`, `label`

4. **每次修改 ARB 文件后重新生成**：记得运行 `flutter gen-l10n` 或 `flutter run` 会自动生成。

## 参数化字符串

如果需要在字符串中插入动态内容，可以使用占位符：

**app_en.arb:**
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "A greeting message",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**使用方式:**
```dart
Text(l10n.greeting('World'))  // 输出: Hello, World!
```

## 常见问题

### Q: 修改了 ARB 文件但没有生效？
A: 运行 `flutter gen-l10n` 重新生成本地化文件。

### Q: 提示找不到 AppLocalizations？
A: 确保在 `pubspec.yaml` 中设置了 `generate: true`，并且运行了 `flutter pub get`。

### Q: 如何添加新的语言？
A:
1. 创建新的 ARB 文件，如 `app_fr.arb`
2. 在 ARB 文件中设置 `"@@locale": "fr"`
3. 运行 `flutter gen-l10n`
4. 新的语言会自动添加到 `supportedLocales`

## 更多信息

- [Flutter 国际化官方文档](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB 文件格式规范](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
