//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ENUM_INDICATOR_OTHER_DEFINED
// Defines enum with supported indicator list.
enum ENUM_INDICATOR_OTHER {
  INDI_OTHER_0_NONE = 0,             // (None)
  INDI_OTHER_MISC_ATR_MA_TREND,      // Misc: ATR MA Trend
  INDI_OTHER_OSC_SUPERSLOPE,         // Oscillator: Super Slope
  INDI_OTHER_OSC_MULTI_EWO2,         // Oscillator: Elliott Wave Oscillator 2
  INDI_OTHER_OSC_MULTI_TDI,          // Oscillator: TDI (Traders Dynamic Index)
  INDI_OTHER_OSC_MULTI_TDI_RT_CLONE, // Oscillator: TDI-RT-Clone
  INDI_OTHER_OSC_MULTI_TMA_CG,       // Oscillator: TMA CG
  INDI_OTHER_PRICE_MULTI_OHLC_HA_SMOOTHED, // Price/Range: SVE Bollinger Bands
  INDI_OTHER_PRICE_RANGE_SVE_BB,           // Price/Range: SVE Bollinger Bands
};
#define ENUM_INDICATOR_OTHER_DEFINED
#endif
