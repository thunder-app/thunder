import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';

enum CustomThemeType {
  material(label: 'Material', color: FlexColor.materialLightPrimary),
  materialHc(label: 'Material High Contrast', color: FlexColor.materialLightPrimaryHc),
  blue(label: 'Blue', color: FlexColor.blueLightPrimary),
  indigo(label: 'Indigo', color: FlexColor.indigoLightPrimary),
  hippieBlue(label: 'Hippie Blue', color: FlexColor.hippieBlueLightPrimary),
  aquaBlue(label: 'Aqua Blue', color: FlexColor.aquaBlueLightPrimary),
  brandBlue(label: 'Brand Blue', color: FlexColor.brandBlueLightPrimary),
  deepBlue(label: 'Deep Blue', color: FlexColor.deepBlueLightPrimary),
  sakura(label: 'Sakura', color: FlexColor.sakuraLightPrimary),
  mandyRed(label: 'Mandy Red', color: FlexColor.mandyRedLightPrimary),
  red(label: 'Red', color: FlexColor.redLightPrimary),
  redWine(label: 'Red Wine', color: FlexColor.redWineLightPrimary),
  purpleBrown(label: 'Purple Brown', color: FlexColor.purpleBrownLightPrimary),
  green(label: 'Green', color: FlexColor.greenLightPrimary),
  money(label: 'Money', color: FlexColor.moneyLightPrimary),
  jungle(label: 'Jungle', color: FlexColor.jungleLightPrimary),
  greyLaw(label: 'Grey Law', color: FlexColor.greyLawLightPrimary),
  wasabi(label: 'Wasabi', color: FlexColor.wasabiLightPrimary),
  gold(label: 'Gold', color: FlexColor.goldLightPrimary),
  mango(label: 'Mango', color: FlexColor.mangoLightPrimary),
  amber(label: 'Amber', color: FlexColor.amberLightPrimary),
  vesuviusBurn(label: 'Vesuvius Burn', color: FlexColor.vesuviusBurnLightPrimary),
  deepPurple(label: 'Deep Purple', color: FlexColor.deepPurpleLightPrimary),
  ebonyClay(label: 'Ebony Clay', color: FlexColor.ebonyClayLightPrimary),
  barossa(label: 'Barossa', color: FlexColor.barossaLightPrimary),
  shark(label: 'Shark', color: FlexColor.sharkLightPrimary),
  bigStone(label: 'Big Stone', color: FlexColor.bigStoneLightPrimary),
  damask(label: 'Damask', color: FlexColor.damaskLightPrimary),
  bahamaBlue(label: 'Bahama Blue', color: FlexColor.bahamaBlueLightPrimary),
  mallardGreen(label: 'Mallard Green', color: FlexColor.mallardGreenLightPrimary),
  espresso(label: 'Espresso', color: FlexColor.espressoLightPrimary),
  outerSpace(label: 'Outer Space', color: FlexColor.outerSpaceLightPrimary),
  blueWhale(label: 'Blue Whale', color: FlexColor.blueWhaleLightPrimary),
  sanJuanBlue(label: 'San Juan Blue', color: FlexColor.sanJuanBlueLightPrimary),
  rosewood(label: 'Rosewood', color: FlexColor.rosewoodLightPrimary),
  blumineBlue(label: 'Blumine Blue', color: FlexColor.blumineBlueLightPrimary),
  materialBaseline(label: 'Material Baseline', color: FlexColor.materialBaselineLightPrimary),
  verdunHemlock(label: 'Verdun Hemlock', color: FlexColor.verdunHemlockLightPrimary),
  dellGenoa(label: 'Dell Genoa', color: FlexColor.dellGenoaGreenLightPrimary),
  redM3(label: 'Red', color: FlexColor.redM3LightPrimary),
  pinkM3(label: 'Pink', color: FlexColor.pinkM3LightPrimary),
  purpleM3(label: 'Purple', color: FlexColor.purpleM3LightPrimary),
  indigoM3(label: 'Indigo', color: FlexColor.indigoM3LightPrimary),
  blueM3(label: 'Blue', color: FlexColor.blueM3LightPrimary),
  cyanM3(label: 'Cyan', color: FlexColor.cyanM3LightPrimary),
  tealM3(label: 'Teal', color: FlexColor.tealM3LightPrimary),
  greenM3(label: 'Green', color: FlexColor.greenM3LightPrimary),
  limeM3(label: 'Lime', color: FlexColor.limeM3LightPrimary),
  yellowM3(label: 'Yellow', color: FlexColor.yellowM3LightPrimary),
  orangeM3(label: 'Orange', color: FlexColor.orangeM3LightPrimary),
  deepOrangeM3(label: 'Deep Orange', color: FlexColor.deepOrangeM3LightPrimary);

  const CustomThemeType({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}
