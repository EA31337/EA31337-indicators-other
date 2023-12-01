/*------------------------------------------------------------------------------------
   Name: TDI-RT-Clone.mq4

   Description: A clone of the TDI indicator.
                The volatility bands and the market base line are not exactly
the same but they are close enough.

-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "www.xaphod.com"
#property link "www.xaphod.com"
#property strict
#property version "1.600"
#property description "A clone of the TDI-RT indicator"
#property description "RT indicating that it updates in Real Time, ie on every tick."
#property description "The volatility bands and the market base line are not exactly the same but they are close enough."
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_color2 clrBlue
#property indicator_width2 1
#property indicator_color3 clrYellow
#property indicator_width3 1
#property indicator_color4 clrRed
#property indicator_width4 2
#property indicator_color5 clrGreen
#property indicator_width5 2
#property indicator_color6 clrWhite
#property indicator_width6 1
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DimGray

#define INDICATOR_NAME "TDI-RT-Clone"

// Indicator parameters
extern int RSI_Period = 13;
extern ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE;
extern int Volatility_Band = 34;
extern int RSISignal_Period = 2;
extern ENUM_MA_METHOD RSISignal_Mode = MODE_SMA;
extern int TradeSignal_Period = 7;
extern ENUM_MA_METHOD TradeSignal_Mode = MODE_SMA;

// Global module varables
double gdaRSI[];
double gdaRSISig[];
double gdaTradeSig[];
double gdaMktBase[];
double gdaVolaTop[];
double gdaVolaBtm[];

//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, gdaVolaTop);
  SetIndexLabel(0, "Volatility Top");
  SetIndexStyle(1, DRAW_LINE);
  SetIndexBuffer(1, gdaVolaBtm);
  SetIndexLabel(1, "Volatility Bottom");
  SetIndexStyle(2, DRAW_LINE);
  SetIndexBuffer(2, gdaMktBase);
  SetIndexLabel(3, "Market Base");
  SetIndexStyle(3, DRAW_LINE);
  SetIndexBuffer(3, gdaTradeSig);
  SetIndexLabel(3, "Trade Signal");
  SetIndexStyle(4, DRAW_LINE);
  SetIndexBuffer(4, gdaRSISig);
  SetIndexLabel(4, "RSI Signal");

  SetIndexStyle(5, DRAW_LINE);
  SetIndexBuffer(5, gdaRSI);
  SetIndexLabel(5, NULL);
  IndicatorDigits(1);
  IndicatorShortName(INDICATOR_NAME);
  return (0);
}

//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() { return (0); }

///-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int iNewBars, iCountedBars, i;

  // Get unprocessed bars
  iCountedBars = IndicatorCounted();
  if (iCountedBars < 0)
    return (-1);
  if (iCountedBars > 0)
    iCountedBars--;
  iNewBars = MathMin(Bars - iCountedBars, Bars - 1);

  int bars = Bars;

  // Calc TDI data
  for (i = iNewBars - 1; i >= 0; i--) {
    // NOT SERIES:
    // gdaRSI[8] = iRSI(NULL, 0, 13,         PRICE_CLOSE, 8(shift)); <- RSI over
    // bars: >-11 ..      [>0, >1, 2, 3, 4, 5, 6, 7, 8, 9] gdaRSI[7] =
    // iRSI(NULL, 0, 13,         PRICE_CLOSE, 7(shift)); <- RSI over bars: >-12
    // ..      [>0,  1, 2, 3, 4, 5, 6, 7, 8, 9] gdaRSI[6] = iRSI(NULL, 0, 13,
    // PRICE_CLOSE, 6(shift)); <- RSI over bars: >-13 .. >-1, [ 0,  1, 2, 3, 4,
    // 5, 6, 7, 8, 9]

    // SERIES:
    // gdaRSI[8] = iRSI(NULL, 0, 13,         PRICE_CLOSE, 8(shift)); <- RSI over
    // bars: [0, >1, >2, >3, >4, >5, >6, >7, >8, >9] .. >13 gdaRSI[7] =
    // iRSI(NULL, 0, 13,         PRICE_CLOSE, 7(shift)); <- RSI over bars: [0,
    // 1, >2, >3, >4, >5, >6, >7, >8, >9] .. >14 gdaRSI[6] = iRSI(NULL, 0, 13,
    // PRICE_CLOSE, 6(shift)); <- RSI over bars: [0,  1,  2, >3, >4, >5, >6, >7,
    // >8, >9] .. >15
    gdaRSI[i] = iRSI(NULL, 0, RSI_Period, RSI_Price, i);

    // gdaRSI[i] = 50.0 + (50.0 / 32768 * rand());

    // Print("gdaRSI[", i, "] = ", gdaRSI[i]);
  }

  double a[];
  ArrayResize(a, 10);
  for (int i = 0; i < ArraySize(a); ++i) {
    a[i] = (double)i;
  }
  ArraySetAsSeries(a, true);

  double r1 = iMAOnArray(a, 5, 5, 0, MODE_SMA, 0);
  double r2 = iStdDevOnArray(a, 5, 5, 0, MODE_SMA, 0);
  double r3 = iRSI(NULL, PERIOD_CURRENT, RSI_Period, RSI_Price, 0);
  double r4 = iRSI(NULL, PERIOD_CURRENT, RSI_Period, RSI_Price, 1);

  /*
    Let's say that iNewBars is 9.
    9 because Bars = 10, so there's 10 bars in history and iNewBars is Bars - 1:
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] <- By default index buffers in MQL5 have
    normal indexing (not series). 0 - first bar, 9 - last/current bar. ^  ^  ^
    ^  ^  ^  ^  ^ We iterate over above bars^: 0..(iNewBars(9) - 1) = indices
    0..8 That means that we iterate from the penulitmate received bar (shift 2,
    as 9 is the latest/current bar) to the initial bar (shift 9).
  */

  for (i = iNewBars - 1; i >= 0; i--) {
    // gdaRSISig[8] = iMAOnArray(gdaRSI, 9,       2,                 0,
    // MODE_SMA,      8) gdaRSISig[7] = iMAOnArray(gdaRSI, 9,       2, 0,
    // MODE_SMA,      7)
    gdaRSISig[i] =
        iMAOnArray(gdaRSI, 0, RSISignal_Period, 0, RSISignal_Mode, i);

    gdaTradeSig[i] =
        iMAOnArray(gdaRSI, 0, TradeSignal_Period, 0, TradeSignal_Mode, i);
    gdaMktBase[i] = iMAOnArray(gdaRSI, 0, Volatility_Band, 0, MODE_SMA, i);
    double stdDev1, stdDev2;
    gdaVolaTop[i] = gdaMktBase[i] +
                    1.6185 * (stdDev1 = iStdDevOnArray(
                                  gdaRSI, 0, Volatility_Band, 0, MODE_SMA, i));
    gdaVolaBtm[i] = gdaMktBase[i] -
                    1.6185 * (stdDev2 = iStdDevOnArray(
                                  gdaRSI, 0, Volatility_Band, 0, MODE_SMA, i));

    // if (ArraySize(gdaRSI) > i + 5)
    if (iNewBars == 1 && false)
      Alert(Bars, ", ", i, ": ", gdaTradeSig[i], ", ", gdaMktBase[i], ", ",
            gdaVolaTop[i], ", ", gdaVolaBtm[i], ", RSI: ", gdaRSI[i], ", ",
            gdaRSI[i + 1], ", ", gdaRSI[i + 2], ", ", gdaRSI[i + 3], ", ",
            gdaRSI[i + 4], ", StdDev: ", stdDev1, ", ", stdDev2,
            ", iNewBars = ", iNewBars, ", Bars = ", Bars);

    // gdaRSI[i] = -100;
  }
  return (0);
}
//+------------------------------------------------------------------+
