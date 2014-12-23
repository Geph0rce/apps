//
//  PandoraColors.h
//  Zen
//
//  Created by roger on 14-7-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#ifndef Pandora_PandoraColors_h
#define Pandora_PandoraColors_h

#define PandoraColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define kPandoraColorMidGreen  PandoraColorFromRGB(0x1abc9c)
#define kPandoraColorMidGreenHL PandoraColorFromRGB(0x16a085)

#define kPandoraColorLightGreen PandoraColorFromRGB(0x2ecc71)
#define kPandoraColorLightGreenHL PandoraColorFromRGB(0x27ae60)

#define kPandoraColorRealBlue PandoraColorFromRGB(0x3498db)
#define kPandoraColorRealBlueHL PandoraColorFromRGB(0x2980b9)

#define kPandoraColorLightBlue PandoraColorFromRGB(0x21aabd)
#define kPandoraColorLightBlueHL PandoraColorFromRGB(0x15707c)

#define kPandoraColorPurple PandoraColorFromRGB(0x654b6b)
#define kPandoraColorPurpleHL PandoraColorFromRGB(0x443248)

#define kPandoraColorNavy PandoraColorFromRGB(0x34495e)
#define kPandoraColorNavyHL PandoraColorFromRGB(0x2c3e50)

#define kPandoraColorOrange PandoraColorFromRGB(0xe67e22)
#define kPandoraColorOrangeHL PandoraColorFromRGB(0xd35400)

#define kPandoraColorRed PandoraColorFromRGB(0xe74c3c)
#define kPandoraColorRedHL PandoraColorFromRGB(0xc0392b)

#define kPandoraColorGray PandoraColorFromRGB(0x95a5a6)
#define kPandoraColorGrayHL PandoraColorFromRGB(0x7f8c8d)

#endif
