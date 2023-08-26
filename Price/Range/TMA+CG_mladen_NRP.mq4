//+------------------------------------------------------------------+
//|                                                       TMA+CG.mq4 |
//|                                                           mladen |
//| Arrows coded according to idea presented by rajiv                |
//| Modified by kenorb (2020)                                        |
//+------------------------------------------------------------------+
#property copyright "rajivxxx"
#property link "rajivxxx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 clrNONE
#property indicator_color2 Coral
#property indicator_color3 Coral
#property indicator_color4 Green
#property indicator_color5 Maroon
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

//
//
//
//
//

// External variables.
extern bool CalculateTma = false;
extern bool ReturnBars = false;
extern int HalfLength = 61;
extern int AtrPeriod = 20;
extern double BandsDeviations = 2.8;
extern ENUM_APPLIED_PRICE MaAppliedPrice = PRICE_WEIGHTED;
extern ENUM_MA_METHOD MaMethod = MODE_SMA;
extern int MaPeriod = 1;
extern int SignalDuration = 3;
extern bool Interpolate = true;
extern bool AlertsOn = false;
extern bool AlertsOnCurrent = false;
extern bool AlertsOnHighLow = false;

// Internal variables.
bool alertsEmail = false;
bool alertsMessage = false;
bool alertsNotification = false;
bool alertsSound = false;

//
//
//
//
//

double tmBuffer[];
double upBuffer[];
double dnBuffer[];
double wuBuffer[];
double wdBuffer[];
double upArrow[];
double dnArrow[];

//
//
//
//
//

string IndicatorFileName;
bool returningBars = false;
int halfLength = HalfLength;
int up_counter, down_counter;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
datetime time;
int init() {
  halfLength = MathMax(HalfLength, 1);
  IndicatorBuffers(7);
  SetIndexBuffer(0, tmBuffer);
  SetIndexBuffer(1, upBuffer);
  SetIndexBuffer(2, dnBuffer);
  SetIndexBuffer(3, dnArrow);
  SetIndexBuffer(4, upArrow);
  SetIndexBuffer(5, wuBuffer);
  SetIndexBuffer(6, wdBuffer);

  SetIndexDrawBegin(0, HalfLength);
  SetIndexDrawBegin(1, HalfLength);
  SetIndexDrawBegin(2, HalfLength);

  SetIndexStyle(3, DRAW_ARROW);
  SetIndexArrow(3, 233);
  SetIndexStyle(4, DRAW_ARROW);
  SetIndexArrow(4, 234);

  IndicatorFileName = WindowExpertName();
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

int start() {
  int counted_bars = IndicatorCounted();
  int i, limit;

  if (counted_bars < 0)
    return (-1);
  if (counted_bars > 0)
    counted_bars--;
  limit = MathMin(Bars - AtrPeriod, Bars - counted_bars + HalfLength);

  if (ReturnBars) {
    tmBuffer[0] = limit;
    return (0);
  }
  if (CalculateTma) {
    return calculateTma(limit) ? 0 : -1;
  }

  // @fixme: Is this needed?
  // double _bar_limit = iCustom(_Symbol, PERIOD_CURRENT, IndicatorFileName,
  // false, true); limit = MathMax(limit, MathMin(Bars - 1, _bar_limit *
  // PERIOD_CURRENT / Period()));

  for (i = limit; i >= 0; i--) {
    int shift1 = iBarShift(_Symbol, PERIOD_CURRENT, Time[i]);
    datetime time1 = iTime(_Symbol, PERIOD_CURRENT, shift1);

    //
    //
    //
    //
    //

    tmBuffer[i] =
        iCustom(_Symbol, PERIOD_CURRENT, IndicatorFileName, true, false,
                HalfLength, AtrPeriod, BandsDeviations, MaAppliedPrice,
                MaMethod, MaPeriod, SignalDuration, Interpolate, 0, shift1);

    upBuffer[i] =
        iCustom(_Symbol, PERIOD_CURRENT, IndicatorFileName, true, false,
                HalfLength, AtrPeriod, BandsDeviations, MaAppliedPrice,
                MaMethod, MaPeriod, SignalDuration, Interpolate, 1, shift1);

    dnBuffer[i] =
        iCustom(_Symbol, PERIOD_CURRENT, IndicatorFileName, true, false,
                HalfLength, AtrPeriod, BandsDeviations, MaAppliedPrice,
                MaMethod, MaPeriod, SignalDuration, Interpolate, 2, shift1);

    double _atr = iATR(_Symbol, PERIOD_CURRENT, AtrPeriod, i);

#ifdef __debug__
    Print("iCustoms: #0 = ", DoubleToString(tmBuffer[i]),
          ", #1 = ", DoubleToString(upBuffer[i]),
          ", #2 = ", DoubleToString(dnBuffer[i]), ", Error = ", _LastError);
#endif

    if (GetLastError() != ERR_NO_ERROR) {
      // Ignore missing indicator data.
      ResetLastError();
      continue;
    }

    upArrow[i] = EMPTY_VALUE;
    dnArrow[i] = EMPTY_VALUE;
    if (High[i + 1] > upBuffer[i + 1] && Close[i + 1] > Open[i + 1] &&
        Close[i] < Open[i]) {
      upArrow[i] = High[i] + _atr;
    }
    if (Low[i + 1] < dnBuffer[i + 1] && Close[i + 1] < Open[i + 1] &&
        Close[i] > Open[i]) {
      dnArrow[i] = High[i] - _atr;
    }

    if (upArrow[i] != EMPTY_VALUE) {
      up_counter++;
    } else if (up_counter > 0 && up_counter < SignalDuration) {
      upArrow[i] = High[i] + _atr;
      up_counter++;
    } else
      up_counter = 0;

    if (dnArrow[i] != EMPTY_VALUE) {
      down_counter++;
    } else if (down_counter > 0 && down_counter < SignalDuration) {
      dnArrow[i] = High[i] - _atr;
      down_counter++;
    } else
      down_counter = 0;

    if (PERIOD_CURRENT <= Period() ||
        shift1 == iBarShift(_Symbol, PERIOD_CURRENT, Time[i - 1]))
      continue;
    if (!Interpolate)
      continue;

    //
    //
    //
    //
    //

    int n = 1;
    for (n = 1; i + n < Bars && Time[i + n] >= time1; n++)
      continue;
    double factor = 1.0 / n;
    for (int k = 1; k < n; k++) {
      tmBuffer[i + k] =
          k * factor * tmBuffer[i + n] + (1.0 - k * factor) * tmBuffer[i];
      upBuffer[i + k] =
          k * factor * upBuffer[i + n] + (1.0 - k * factor) * upBuffer[i];
      dnBuffer[i + k] =
          k * factor * dnBuffer[i + n] + (1.0 - k * factor) * dnBuffer[i];
    }
  }

  //
  //
  //
  //
  //

  if (AlertsOn) {
    int forBar = AlertsOnCurrent ? 0 : 1;
    if (AlertsOnHighLow) {
      if (High[forBar] > upBuffer[forBar] &&
          High[forBar + 1] < upBuffer[forBar + 1])
        doAlert("High penetrated upper bar");
      if (Low[forBar] < dnBuffer[forBar] &&
          Low[forBar + 1] > dnBuffer[forBar + 1])
        doAlert("low penetrated lower bar");
    } else {
      if (Close[forBar] > upBuffer[forBar] &&
          Close[forBar + 1] < upBuffer[forBar + 1])
        doAlert("Close penetrated upper bar");
      if (Close[forBar] < dnBuffer[forBar] &&
          Close[forBar + 1] > dnBuffer[forBar + 1])
        doAlert("Close penetrated lower bar");
    }
  }

  return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

bool calculateTma(int limit) {
  int i, j, k;
  double FullLength = 2.0 * HalfLength + 1.0;

  //
  //
  //
  //
  //

  for (i = limit; i >= 0; i--) {
    double sum = (HalfLength + 1) * iMA(_Symbol, PERIOD_CURRENT, MaPeriod, 0,
                                        MaMethod, MaAppliedPrice, i);
    double sumw = (HalfLength + 1);

    if (GetLastError() != ERR_NO_ERROR) {
      // Ignore missing indicator data.
      ResetLastError();
      continue;
    }

    for (j = 1, k = HalfLength; j <= HalfLength; j++, k--) {
      sum += k * iMA(_Symbol, PERIOD_CURRENT, MaPeriod, 0, MaMethod,
                     MaAppliedPrice, i + j);

      sumw += k;

      if (j <= i) {
        sum += k * iMA(_Symbol, PERIOD_CURRENT, MaPeriod, 0, MaMethod,
                       MaAppliedPrice, i - j);

        if (GetLastError() != ERR_NO_ERROR) {
          // Missing data for iMA.
          ResetLastError();
          return false;
        }

        sumw += k;
      }
    }
    tmBuffer[i] = sum / sumw;

    //
    //
    //
    //
    //

    double diff =
        iMA(_Symbol, PERIOD_CURRENT, MaPeriod, 0, MaMethod, MaAppliedPrice, i) -
        tmBuffer[i];
    if (i > (Bars - HalfLength - 1))
      continue;
    if (i == (Bars - HalfLength - 1)) {
      upBuffer[i] = tmBuffer[i];
      dnBuffer[i] = tmBuffer[i];

      //      Print("Setting value into wdBuffer[", i, "] where
      //      ArraySize(wdBuffer) = ", ArraySize(wdBuffer));

      if (diff >= 0) {
        wuBuffer[i] = MathPow(diff, 2);
        wdBuffer[i] = 0;
      } else {
        wdBuffer[i] = MathPow(diff, 2);
        wuBuffer[i] = 0;
      }
      continue;
    }

    //
    //
    //
    //
    //

    if (diff >= 0) {
      wuBuffer[i] =
          (wuBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
      wdBuffer[i] = wdBuffer[i + 1] * (FullLength - 1) / FullLength;
    } else {
      wdBuffer[i] =
          (wdBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
      wuBuffer[i] = wuBuffer[i + 1] * (FullLength - 1) / FullLength;
    }
    upBuffer[i] = tmBuffer[i] + BandsDeviations * MathSqrt(wuBuffer[i]);
    dnBuffer[i] = tmBuffer[i] - BandsDeviations * MathSqrt(wdBuffer[i]);

#ifdef __debug__
    Print("upBuffer[", i, "] = ", DoubleToString(upBuffer[i]));
    Print("dnBuffer[", i, "] = ", DoubleToString(dnBuffer[i]));
    Print("wuBuffer[", i, "] = ", DoubleToString(wuBuffer[i]));
    Print("wdBuffer[", i, "] = ", DoubleToString(wdBuffer[i]));
    Print(" upArrow[", i, "] = ", DoubleToString(upArrow[i]));
    Print(" dnArrow[", i, "] = ", DoubleToString(dnArrow[i]));
#endif
  }

  return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void doAlert(string doWhat) {
  static string previousAlert = "";
  static datetime previousTime;
  string message;

  //
  //
  //
  //
  //

  if (previousAlert != doWhat || previousTime != Time[0]) {
    previousAlert = doWhat;
    previousTime = Time[0];

    message = StringFormat("%s at %s; THA: %s", _Symbol,
                           TimeToStr(TimeLocal(), TIME_SECONDS), doWhat);
    if (alertsEmail)
      SendMail(StringFormat("%s %s", _Symbol, "TMA"), message);
    if (alertsMessage)
      Alert(message);
    if (alertsNotification)
      SendNotification(message);
    if (alertsSound)
      PlaySound("alert2.wav");
  }
}
