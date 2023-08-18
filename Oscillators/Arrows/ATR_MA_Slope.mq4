#property indicator_buffers 4
#property indicator_separate_window

extern int NumberOfBars = 100;
extern double SlopeThreshold = 2.0;
extern int SlopeMAPeriod = 7;
extern int SlopeATRPeriod = 50;

extern color SlopeColor = Gray;
extern color LongColor = Lime;
extern color ShortColor = Red;

double Slope[];
double Long[];
double Short[];
double Flat[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  IndicatorShortName(WindowExpertName());

  SetIndexBuffer(0, Slope);
  SetIndexBuffer(1, Long);
  SetIndexBuffer(2, Short);
  SetIndexBuffer(3, Flat);

  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, SlopeColor);
  SetIndexLabel(0, "Slope");
  SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1, LongColor);
  SetIndexLabel(1, "Long");
  SetIndexArrow(1, 159);
  SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1, ShortColor);
  SetIndexLabel(2, "Short");
  SetIndexArrow(2, 159);
  SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1, SlopeColor);
  SetIndexLabel(3, "Flat");
  SetIndexArrow(3, 159);

  // SetLevelStyle(STYLE_SOLID, 1, SlopeColor);
  // SetLevelValue(0, SlopeThreshold * 0.5);
  // SetLevelValue(1, -SlopeThreshold * 0.5);

  return (INIT_SUCCEEDED);
}

int start() {
  int prev_calculated = IndicatorCounted();
  int rates_total = Bars;
  int limit = MathMin(NumberOfBars, rates_total - prev_calculated);
  if (limit == rates_total)
    limit--;

  for (int shift = limit; shift >= 0; shift--) {
    Slope[shift] = 0;

    double dblTma, dblPrev;
    double atr = iATR(NULL, PERIOD_CURRENT, SlopeATRPeriod, shift + 10) / 10;

    if (atr != 0) {
      dblTma = iMA(NULL, PERIOD_CURRENT, SlopeMAPeriod, 0, MODE_LWMA,
                   PRICE_CLOSE, shift);
      dblPrev = (iMA(NULL, PERIOD_CURRENT, SlopeMAPeriod, 0, MODE_LWMA,
                     PRICE_CLOSE, shift + 1) *
                     231 +
                 iClose(NULL, (int)PERIOD_CURRENT, shift) * 20) /
                251;
      Slope[shift] = (dblTma - dblPrev) / atr;
    }

    Long[shift] = EMPTY_VALUE;
    Short[shift] = EMPTY_VALUE;
    Flat[shift] = EMPTY_VALUE;

    if (Slope[shift] > SlopeThreshold * 0.5)
      Long[shift] = Slope[shift];
    else if (Slope[shift] < -SlopeThreshold * 0.5)
      Short[shift] = Slope[shift];
    else
      Flat[shift] = Slope[shift];
  }

  return (0);
}
