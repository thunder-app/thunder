import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';

enum CustomThemeType {
  material(label: 'Material', primaryColor: FlexColor.materialLightPrimary, secondaryColor: FlexColor.materialLightPrimaryContainer, tertiaryColor: FlexColor.materialLightSecondaryContainer),
  materialHc(
      label: 'Material High Contrast',
      primaryColor: FlexColor.materialLightPrimaryHc,
      secondaryColor: FlexColor.materialLightPrimaryContainerHc,
      tertiaryColor: FlexColor.materialLightSecondaryContainerHc),
  blue(label: 'Blue', primaryColor: FlexColor.blueLightPrimary, secondaryColor: FlexColor.blueLightPrimaryContainer, tertiaryColor: FlexColor.blueLightSecondaryContainer),
  indigo(label: 'Indigo', primaryColor: FlexColor.indigoLightPrimary, secondaryColor: FlexColor.indigoLightPrimaryContainer, tertiaryColor: FlexColor.indigoLightSecondaryContainer),
  hippieBlue(
      label: 'Hippie Blue', primaryColor: FlexColor.hippieBlueLightPrimary, secondaryColor: FlexColor.hippieBlueLightPrimaryContainer, tertiaryColor: FlexColor.hippieBlueLightSecondaryContainer),
  aquaBlue(label: 'Aqua Blue', primaryColor: FlexColor.aquaBlueLightPrimary, secondaryColor: FlexColor.aquaBlueLightPrimaryContainer, tertiaryColor: FlexColor.aquaBlueLightSecondaryContainer),
  brandBlue(label: 'Brand Blue', primaryColor: FlexColor.brandBlueLightPrimary, secondaryColor: FlexColor.brandBlueLightPrimaryContainer, tertiaryColor: FlexColor.brandBlueLightSecondaryContainer),
  deepBlue(label: 'Deep Blue', primaryColor: FlexColor.deepBlueLightPrimary, secondaryColor: FlexColor.deepBlueLightPrimaryContainer, tertiaryColor: FlexColor.deepBlueLightSecondaryContainer),
  sakura(label: 'Sakura', primaryColor: FlexColor.sakuraLightPrimary, secondaryColor: FlexColor.sakuraLightPrimaryContainer, tertiaryColor: FlexColor.sakuraLightSecondaryContainer),
  mandyRed(label: 'Mandy Red', primaryColor: FlexColor.mandyRedLightPrimary, secondaryColor: FlexColor.mandyRedLightPrimaryContainer, tertiaryColor: FlexColor.mandyRedLightSecondaryContainer),
  red(label: 'Red', primaryColor: FlexColor.redLightPrimary, secondaryColor: FlexColor.redLightPrimaryContainer, tertiaryColor: FlexColor.redLightSecondaryContainer),
  redWine(label: 'Red Wine', primaryColor: FlexColor.redWineLightPrimary, secondaryColor: FlexColor.redWineLightPrimaryContainer, tertiaryColor: FlexColor.redWineLightSecondaryContainer),
  purpleBrown(
      label: 'Purple Brown', primaryColor: FlexColor.purpleBrownLightPrimary, secondaryColor: FlexColor.purpleBrownLightPrimaryContainer, tertiaryColor: FlexColor.purpleBrownLightSecondaryContainer),
  green(label: 'Green', primaryColor: FlexColor.greenLightPrimary, secondaryColor: FlexColor.greenLightPrimaryContainer, tertiaryColor: FlexColor.greenLightSecondaryContainer),
  money(label: 'Money', primaryColor: FlexColor.moneyLightPrimary, secondaryColor: FlexColor.moneyLightPrimaryContainer, tertiaryColor: FlexColor.moneyLightSecondaryContainer),
  jungle(label: 'Jungle', primaryColor: FlexColor.jungleLightPrimary, secondaryColor: FlexColor.jungleLightPrimaryContainer, tertiaryColor: FlexColor.jungleLightSecondaryContainer),
  greyLaw(label: 'Grey Law', primaryColor: FlexColor.greyLawLightPrimary, secondaryColor: FlexColor.greyLawLightPrimaryContainer, tertiaryColor: FlexColor.greyLawLightSecondaryContainer),
  wasabi(label: 'Wasabi', primaryColor: FlexColor.wasabiLightPrimary, secondaryColor: FlexColor.wasabiLightPrimaryContainer, tertiaryColor: FlexColor.wasabiLightSecondaryContainer),
  gold(label: 'Gold', primaryColor: FlexColor.goldLightPrimary, secondaryColor: FlexColor.goldLightPrimaryContainer, tertiaryColor: FlexColor.goldLightSecondaryContainer),
  mango(label: 'Mango', primaryColor: FlexColor.mangoLightPrimary, secondaryColor: FlexColor.mangoLightPrimaryContainer, tertiaryColor: FlexColor.mangoLightSecondaryContainer),
  amber(label: 'Amber', primaryColor: FlexColor.amberLightPrimary, secondaryColor: FlexColor.amberLightPrimaryContainer, tertiaryColor: FlexColor.amberLightSecondaryContainer),
  vesuviusBurn(
      label: 'Vesuvius Burn',
      primaryColor: FlexColor.vesuviusBurnLightPrimary,
      secondaryColor: FlexColor.vesuviusBurnLightPrimaryContainer,
      tertiaryColor: FlexColor.vesuviusBurnLightSecondaryContainer),
  deepPurple(
      label: 'Deep Purple', primaryColor: FlexColor.deepPurpleLightPrimary, secondaryColor: FlexColor.deepPurpleLightPrimaryContainer, tertiaryColor: FlexColor.deepPurpleLightSecondaryContainer),
  ebonyClay(label: 'Ebony Clay', primaryColor: FlexColor.ebonyClayLightPrimary, secondaryColor: FlexColor.ebonyClayLightPrimaryContainer, tertiaryColor: FlexColor.ebonyClayLightSecondaryContainer),
  barossa(label: 'Barossa', primaryColor: FlexColor.barossaLightPrimary, secondaryColor: FlexColor.barossaLightPrimaryContainer, tertiaryColor: FlexColor.barossaLightSecondaryContainer),
  shark(label: 'Shark', primaryColor: FlexColor.sharkLightPrimary, secondaryColor: FlexColor.sharkLightPrimaryContainer, tertiaryColor: FlexColor.sharkLightSecondaryContainer),
  bigStone(label: 'Big Stone', primaryColor: FlexColor.bigStoneLightPrimary, secondaryColor: FlexColor.bigStoneLightPrimaryContainer, tertiaryColor: FlexColor.bigStoneLightSecondaryContainer),
  damask(label: 'Damask', primaryColor: FlexColor.damaskLightPrimary, secondaryColor: FlexColor.damaskLightPrimaryContainer, tertiaryColor: FlexColor.damaskLightSecondaryContainer),
  bahamaBlue(
      label: 'Bahama Blue', primaryColor: FlexColor.bahamaBlueLightPrimary, secondaryColor: FlexColor.bahamaBlueLightPrimaryContainer, tertiaryColor: FlexColor.bahamaBlueLightSecondaryContainer),
  mallardGreen(
      label: 'Mallard Green',
      primaryColor: FlexColor.mallardGreenLightPrimary,
      secondaryColor: FlexColor.mallardGreenLightPrimaryContainer,
      tertiaryColor: FlexColor.mallardGreenLightSecondaryContainer),
  espresso(label: 'Espresso', primaryColor: FlexColor.espressoLightPrimary, secondaryColor: FlexColor.espressoLightPrimaryContainer, tertiaryColor: FlexColor.espressoLightSecondaryContainer),
  outerSpace(
      label: 'Outer Space', primaryColor: FlexColor.outerSpaceLightPrimary, secondaryColor: FlexColor.outerSpaceLightPrimaryContainer, tertiaryColor: FlexColor.outerSpaceLightSecondaryContainer),
  blueWhale(label: 'Blue Whale', primaryColor: FlexColor.blueWhaleLightPrimary, secondaryColor: FlexColor.blueWhaleLightPrimaryContainer, tertiaryColor: FlexColor.blueWhaleLightSecondaryContainer),
  sanJuanBlue(
      label: 'San Juan Blue', primaryColor: FlexColor.sanJuanBlueLightPrimary, secondaryColor: FlexColor.sanJuanBlueLightPrimaryContainer, tertiaryColor: FlexColor.sanJuanBlueLightSecondaryContainer),
  rosewood(label: 'Rosewood', primaryColor: FlexColor.rosewoodLightPrimary, secondaryColor: FlexColor.rosewoodLightPrimaryContainer, tertiaryColor: FlexColor.rosewoodLightSecondaryContainer),
  blumineBlue(
      label: 'Blumine Blue', primaryColor: FlexColor.blumineBlueLightPrimary, secondaryColor: FlexColor.blumineBlueLightPrimaryContainer, tertiaryColor: FlexColor.blumineBlueLightSecondaryContainer),
  materialBaseline(
      label: 'Material Baseline',
      primaryColor: FlexColor.materialBaselineLightPrimary,
      secondaryColor: FlexColor.materialBaselineLightPrimaryContainer,
      tertiaryColor: FlexColor.materialBaselineLightSecondaryContainer),
  verdunHemlock(
      label: 'Verdun Hemlock',
      primaryColor: FlexColor.verdunHemlockLightPrimary,
      secondaryColor: FlexColor.verdunHemlockLightPrimaryContainer,
      tertiaryColor: FlexColor.verdunHemlockLightSecondaryContainer),
  dellGenoa(
      label: 'Dell Genoa',
      primaryColor: FlexColor.dellGenoaGreenLightPrimary,
      secondaryColor: FlexColor.dellGenoaGreenLightPrimaryContainer,
      tertiaryColor: FlexColor.dellGenoaGreenLightSecondaryContainer),
  redM3(label: 'Red', primaryColor: FlexColor.redM3LightPrimary, secondaryColor: FlexColor.redM3LightPrimaryContainer, tertiaryColor: FlexColor.redM3LightSecondaryContainer),
  pinkM3(label: 'Pink', primaryColor: FlexColor.pinkM3LightPrimary, secondaryColor: FlexColor.pinkM3LightPrimaryContainer, tertiaryColor: FlexColor.pinkM3LightSecondaryContainer),
  purpleM3(label: 'Purple', primaryColor: FlexColor.purpleM3LightPrimary, secondaryColor: FlexColor.purpleM3LightPrimaryContainer, tertiaryColor: FlexColor.purpleM3LightSecondaryContainer),
  indigoM3(label: 'Indigo', primaryColor: FlexColor.indigoM3LightPrimary, secondaryColor: FlexColor.indigoM3LightPrimaryContainer, tertiaryColor: FlexColor.indigoM3LightSecondaryContainer),
  blueM3(label: 'Blue', primaryColor: FlexColor.blueM3LightPrimary, secondaryColor: FlexColor.blueM3LightPrimaryContainer, tertiaryColor: FlexColor.blueM3LightSecondaryContainer),
  cyanM3(label: 'Cyan', primaryColor: FlexColor.cyanM3LightPrimary, secondaryColor: FlexColor.cyanM3LightPrimaryContainer, tertiaryColor: FlexColor.cyanM3LightSecondaryContainer),
  tealM3(label: 'Teal', primaryColor: FlexColor.tealM3LightPrimary, secondaryColor: FlexColor.tealM3LightPrimaryContainer, tertiaryColor: FlexColor.tealM3LightSecondaryContainer),
  greenM3(label: 'Green', primaryColor: FlexColor.greenM3LightPrimary, secondaryColor: FlexColor.greenM3LightPrimaryContainer, tertiaryColor: FlexColor.greenM3LightSecondaryContainer),
  limeM3(label: 'Lime', primaryColor: FlexColor.limeM3LightPrimary, secondaryColor: FlexColor.limeM3LightPrimaryContainer, tertiaryColor: FlexColor.limeM3LightSecondaryContainer),
  yellowM3(label: 'Yellow', primaryColor: FlexColor.yellowM3LightPrimary, secondaryColor: FlexColor.yellowM3LightPrimaryContainer, tertiaryColor: FlexColor.yellowM3LightSecondaryContainer),
  orangeM3(label: 'Orange', primaryColor: FlexColor.orangeM3LightPrimary, secondaryColor: FlexColor.orangeM3LightPrimaryContainer, tertiaryColor: FlexColor.orangeM3LightSecondaryContainer),
  deepOrangeM3(
      label: 'Deep Orange',
      primaryColor: FlexColor.deepOrangeM3LightPrimary,
      secondaryColor: FlexColor.deepOrangeM3LightPrimaryContainer,
      tertiaryColor: FlexColor.deepOrangeM3LightSecondaryContainer);

  const CustomThemeType({
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });

  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
}
