/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';



class $AssetsImagesGen {
  const $AssetsImagesGen();

 
  AssetGenImage get commonimagefirst => const AssetGenImage('assets/images/commonimagefirst.png');

  AssetGenImage get commonimagesecond => const AssetGenImage('assets/images/commonimagesecond.png');
    
 AssetGenImage get pawllilogo => const AssetGenImage('assets/images/Pawlli_logo.png');
 AssetGenImage get  beagledogsitting => const AssetGenImage('assets/images/beagledogsitting.png');
 AssetGenImage get bestbuddy => const AssetGenImage('assets/images/bestbuddy.png');
 AssetGenImage get catstanding => const AssetGenImage('assets/images/catstanding.png');
 AssetGenImage get sideviewbeagledog => const AssetGenImage('assets/images/sideviewbeagledog.png');
 AssetGenImage get nextvector => const AssetGenImage('assets/images/nextvector.png');
 AssetGenImage get onbodrdingbgimage => const AssetGenImage('assets/images/onbodrdingbgimage.png');
 AssetGenImage get topimage => const AssetGenImage('assets/images/topimage.png');
 AssetGenImage get homeappdog => const AssetGenImage('assets/images/homeappdog.png');
 AssetGenImage get notification => const AssetGenImage('assets/images/notification.png');
 AssetGenImage get homeallbg => const AssetGenImage('assets/images/homeallbg.png');
 AssetGenImage get homeapagebg => const AssetGenImage('assets/images/homepagebg.png');
 AssetGenImage get hpcatstanding => const AssetGenImage('assets/images/hpcatstanding.png');
 AssetGenImage get hpsittingdog => const AssetGenImage('assets/images/hpsittingdog.png');
 AssetGenImage get browncard => const AssetGenImage('assets/images/browncard.png');
 AssetGenImage get yellowcard => const AssetGenImage('assets/images/yellowcard.png');
 AssetGenImage get carddog => const AssetGenImage('assets/images/carddog.png');
 AssetGenImage get allimage => const AssetGenImage('assets/images/allanimals.png');
 AssetGenImage get cat => const AssetGenImage('assets/images/cat.png');
 AssetGenImage get dogcat => const AssetGenImage('assets/images/dogcat.png');
 AssetGenImage get cathome => const AssetGenImage('assets/images/cathome.png');
 AssetGenImage get doghome => const AssetGenImage('assets/images/doghome.png');
 AssetGenImage get whitecat => const AssetGenImage('assets/images/whitecat.png');
 AssetGenImage get downimage => const AssetGenImage('assets/images/downimage.png');
 AssetGenImage get chatbrowcard => const AssetGenImage('assets/images/chatbrowncard.png');
 AssetGenImage get chatyellowcard => const AssetGenImage('assets/images/chatyellowcard.png');
 AssetGenImage get brownbg => const AssetGenImage('assets/images/brownbg.png');
  AssetGenImage get brownradio => const AssetGenImage('assets/images/brownradio.png');
  List<AssetGenImage> get values => [
        pawllilogo,
        commonimagesecond,
        commonimagefirst,
        nextvector,
        beagledogsitting,
        catstanding,
        bestbuddy,
        onbodrdingbgimage,
        sideviewbeagledog,
        homeappdog,
        notification,
        homeallbg,
        homeapagebg,
        hpcatstanding,
        hpsittingdog,
        carddog,
        browncard,
        yellowcard,
        allimage,
        dogcat,
        cathome,
        whitecat,
        doghome,
        downimage,
        chatbrowcard,
        chatyellowcard,
        brownbg,
        brownradio
     
        
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
