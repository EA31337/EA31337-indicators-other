//+------------------------------------------------------------------+
//|                                                                  |
//|                                                                  |
//| original developed by Sylvain Vervoort                           |
//| TASC, May 2010 "Smoothing The Bollinger %b," articlw             |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DeepSkyBlue
#property indicator_color2 LimeGreen
#property indicator_color3 Red
#property indicator_width1 2
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_level1 50

//
//
//
//
//

extern int TEMAPeriod = 8;
extern int SvePeriod = 18;
extern double BBUpDeviations = 1.6;
extern double BBDnDeviations = 1.6;
extern int DeviationsPeriod = 63;

//
//
//
//
//

double bbValue[];
double bbUpper[];
double bbLower[];
double tmaZima[];
double svePerB[];
double tBuffer[][10];
double ialpha;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#include <EA31337-classes/Indicators/Indi_MA.mqh>

int init() {
  IndicatorBuffers(5);
  SetIndexBuffer(0, bbValue);
  SetIndexBuffer(1, bbUpper);
  SetIndexBuffer(2, bbLower);
  SetIndexBuffer(3, tmaZima, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, svePerB, INDICATOR_CALCULATIONS);
  ialpha = 2.0 / (1.0 + TEMAPeriod);
  IndicatorShortName("SVE bollinger band (" + (string)TEMAPeriod + "," + (string)SvePeriod + "," +
                     DoubleToStr(BBUpDeviations, 2) + "," + DoubleToStr(BBDnDeviations, 2) + ")");

  ArraySetAsSeries(bbValue, true);
  ArraySetAsSeries(bbUpper, true);
  ArraySetAsSeries(bbLower, true);

  ArraySetAsSeries(tmaZima, true);
  ArraySetAsSeries(svePerB, true);

  return (0);
}
int deinit() { return (0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define __haOpen 9

//
//
//
//
//

int start() {
  INDICATOR_CALCULATE_POPULATE_CACHE(_Symbol, 0, Util::MakeKey("SVE_BB", TEMAPeriod, SvePeriod, BBUpDeviations, BBDnDeviations, DeviationsPeriod));
  int counted_bars = IndicatorCounted();
  int i, r, limit;

  if (counted_bars < 0) return (-1);
  if (counted_bars > 0) counted_bars--;
  limit = MathMin(Bars - counted_bars, Bars - 1);
  if (ArrayRange(tBuffer, 0) != Bars) ArrayResize(tBuffer, Bars, Bars - Bars % 4096 + 4096);

  // We don't want to process more that 1000 historic bars.
  limit = fmin(limit, 1000);

  for (i = limit, r = Bars - i - 1; i >= 0; i--, r++) {
    if (i == (Bars - 1)) {
      tBuffer[r][__haOpen] = averagePrice(i);
      continue;
    }

    tBuffer[r][__haOpen] = (averagePrice(i) + tBuffer[r - 1][__haOpen]) / 2.0;
    double haClose = (averagePrice(i) + tBuffer[r][__haOpen] + MathMax(High[i], tBuffer[r][__haOpen]) +
                      MathMin(Low[i], tBuffer[r][__haOpen])) /
                     4.0;
    double tema1 = iTema(haClose, i, 0);
    double tema2 = iTema(tema1, i, 3);
    double diff = tema1 - tema2;
    double zima = tema1 + diff;
    tmaZima[i] = iTema(zima, i, 6);
  }

  for (i = limit; i >= 0; i--) {
    double sdev = iDeviation(tmaZima, SvePeriod, i);
    if (sdev != 0)
      svePerB[i] =
          25.0 *
          (tmaZima[i] + 2.0 * sdev - Indi_MA::iMAOnArray(tmaZima, 0, SvePeriod, 0, MODE_LWMA, i, _cache)) /
          sdev;
    else
      svePerB[i] = 0;

    sdev = iDeviation(svePerB, DeviationsPeriod, i);

    bbValue[i] = svePerB[i];
    bbUpper[i] = 50.0 + sdev * BBUpDeviations;
    bbLower[i] = 50.0 - sdev * BBDnDeviations;
  }

  return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double averagePrice(int i) {
  if (Open[i] != 0)
    return ((Open[i] + High[i] + Low[i] + Close[i]) / 4.0);
  else
    return ((High[i] + Low[i] + Close[i]) / 3.0);
}

double iDeviation(double& array[], int period, int pos) {
  double dMA = iSma(array, period, pos);
  double dSum = 0;
  for (int i = 0; i < period && pos < ArrayRange(array, 0); i++, pos++) dSum += (array[pos] - dMA) * (array[pos] - dMA);
  return (MathSqrt(dSum / period));
}

double iSma(double& array[], int period, int pos) {
  double sum = 0.0;
  for (int i = 0; i < period && pos < ArrayRange(array, 0); i++, pos++) sum += array[pos];
  return (sum / period);
}

double iTema(double price, int pos, int sbuf = 0) {
  int i = Bars - pos - 1;
  int ia = sbuf + 0;
  int ib = sbuf + 1;
  int ic = sbuf + 2;

  if (i < 1) {
    tBuffer[i][ia] = price;
    tBuffer[i][ib] = price;
    tBuffer[i][ic] = price;
  } else {
    tBuffer[i][ia] = tBuffer[i - 1][ia] + ialpha * (price - tBuffer[i - 1][ia]);
    tBuffer[i][ib] = tBuffer[i - 1][ib] + ialpha * (tBuffer[i][ia] - tBuffer[i - 1][ib]);
    tBuffer[i][ic] = tBuffer[i - 1][ic] + ialpha * (tBuffer[i][ib] - tBuffer[i - 1][ic]);
  }
  return (3 * tBuffer[i][ia] - 3 * tBuffer[i][ib] + tBuffer[i][ic]);
}
