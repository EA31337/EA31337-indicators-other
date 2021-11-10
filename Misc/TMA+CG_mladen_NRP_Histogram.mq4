// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70514

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

// Based on rajivxxx, rajivxxx@gmail.com, edited by eevviill, no repaint"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_minimum 0
#property indicator_maximum 1

input string TimeFrame = "current time frame";
input int HalfLength = 61;
input int Price = PRICE_WEIGHTED;
input double BandsDeviations = 2.8;
input bool Interpolate = true;
input color up_color = Green; // Up color
input color down_color = Red; // Down color
input int bars_limit = 1000;  // Bars limit

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream {
public:
  virtual void AddRef() = 0;
  virtual void Release() = 0;
  virtual int Size() = 0;

  virtual bool GetValue(const int period, double &val) = 0;
};
  // Instrument info v.1.7
  // More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo {
  string _symbol;
  double _mult;
  double _point;
  double _pipSize;
  int _digits;
  double _tickSize;

public:
  InstrumentInfo(const string symbol) {
    _symbol = symbol;
    _point = MarketInfo(symbol, MODE_POINT);
    _digits = (int)MarketInfo(symbol, MODE_DIGITS);
    _mult = _digits == 3 || _digits == 5 ? 10 : 1;
    _pipSize = _point * _mult;
    _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
  }

  // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
  int CompareLots(double lot1, double lot2) {
    double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
    if (lotStep == 0) {
      return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
    }
    int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
    int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
    int res = lotSteps1 - lotSteps2;
    return res;
  }

  static double GetBid(const string symbol) {
    return MarketInfo(symbol, MODE_BID);
  }
  double GetBid() { return GetBid(_symbol); }
  static double GetAsk(const string symbol) {
    return MarketInfo(symbol, MODE_ASK);
  }
  double GetAsk() { return GetAsk(_symbol); }
  static double GetPipSize(const string symbol) {
    double point = MarketInfo(symbol, MODE_POINT);
    double digits = (int)MarketInfo(symbol, MODE_DIGITS);
    double mult = digits == 3 || digits == 5 ? 10 : 1;
    return point * mult;
  }
  double GetPipSize() { return _pipSize; }
  double GetPointSize() { return _point; }
  string GetSymbol() { return _symbol; }
  double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
  int GetDigits() { return _digits; }
  double GetTickSize() { return _tickSize; }
  double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

  double AddPips(const double rate, const double pips) {
    return RoundRate(rate + pips * _pipSize);
  }

  double RoundRate(const double rate) {
    return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize,
                           _digits);
  }

  double RoundLots(const double lots) {
    double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
    if (lotStep == 0) {
      return 0.0;
    }
    return floor(lots / lotStep) * lotStep;
  }

  double LimitLots(const double lots) {
    double minVolume = GetMinLots();
    if (minVolume > lots) {
      return 0.0;
    }
    double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
    if (maxVolume < lots) {
      return maxVolume;
    }
    return lots;
  }

  double NormalizeLots(const double lots) { return LimitLots(RoundLots(lots)); }
};

#endif

// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public IStream {
protected:
  string _symbol;
  ENUM_TIMEFRAMES _timeframe;
  double _shift;
  InstrumentInfo *_instrument;
  int _references;

  AStream(const string symbol, const ENUM_TIMEFRAMES timeframe) {
    _references = 1;
    _shift = 0.0;
    _symbol = symbol;
    _timeframe = timeframe;
    _instrument = new InstrumentInfo(_symbol);
  }

  ~AStream() { delete _instrument; }

public:
  void SetShift(const double shift) { _shift = shift; }

  void AddRef() { ++_references; }

  void Release() {
    --_references;
    if (_references == 0)
      delete &this;
  }

  int Size() { return iBars(_symbol, _timeframe); }
};
#define AStream_IMP
#endif

// Colored stream v3.2

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData {
public:
  double Stream[];
};

class ColoredStream : public AStream {
public:
  ColoredStreamData _streams[];
  double _data[];

  ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      : AStream(symbol, timeframe) {}

  void Init(double defaultValue) {
    for (int i = 0; i < ArraySize(_streams); ++i) {
      ArrayInitialize(_streams[i].Stream, defaultValue);
    }
    ArrayInitialize(_data, defaultValue);
  }

  int RegisterInternalStream(int id) {
    SetIndexBuffer(id + 0, _data);
    SetIndexStyle(id + 0, DRAW_NONE);
    return id + 1;
  }

  int RegisterStream(int id, color clr, string label = "",
                     int lineType = DRAW_LINE,
                     ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1) {
    int size = ArraySize(_streams);
    ArrayResize(_streams, size + 1);
    SetIndexStyle(id, lineType, lineStyle, width, clr);
    SetIndexBuffer(id, _streams[size].Stream);
#ifndef __MQL4__
    ArraySetAsSeries(_streams[size].Stream, true);
#endif
    SetIndexEmptyValue(id, EMPTY_VALUE);

    if (label != "")
      SetIndexLabel(id, label);
    return id + 1;
  }

  int GetColorIndex(int period) {
    for (int i = 0; i < ArraySize(_streams); ++i) {
      if (_streams[i].Stream[period] != EMPTY_VALUE)
        return i;
    }
    return -1;
  }

  void Set(double value, int period, int colorIndex) {
    _data[period] = value;
    for (int i = 0; i < ArraySize(_streams); ++i) {
      if (colorIndex == i) {
        _streams[i].Stream[period] = value;
        if (period + 1 < iBars(_symbol, _timeframe) &&
            _streams[i].Stream[period + 1] == EMPTY_VALUE)
          _streams[i].Stream[period + 1] = _data[period + 1];
      } else
        _streams[i].Stream[period] = EMPTY_VALUE;
    }
  }

  bool GetValue(const int period, double &val) {
    if (period >= iBars(_symbol, _timeframe)) {
      return false;
    }
    val = _data[period];
    return _data[period] != EMPTY_VALUE;
  }
};

#endif
ColoredStream *out;

string IndicatorFileName;
int init() {
  IndicatorBuffers(3);
  out = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
  int id = 0;
  id = out.RegisterStream(id, up_color, "", DRAW_HISTOGRAM);
  id = out.RegisterStream(id, down_color, "", DRAW_HISTOGRAM);
  id = out.RegisterInternalStream(id);

  IndicatorFileName = WindowExpertName();
  return (0);
}

int deinit() {
  out.Release();
  return (0);
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  if (prev_calculated <= 0 || prev_calculated > rates_total) {
    out.Init(EMPTY_VALUE);
  }
  bool timeSeries = ArrayGetAsSeries(time);
  bool openSeries = ArrayGetAsSeries(open);
  bool highSeries = ArrayGetAsSeries(high);
  bool lowSeries = ArrayGetAsSeries(low);
  bool closeSeries = ArrayGetAsSeries(close);
  bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
  ArraySetAsSeries(time, true);
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  ArraySetAsSeries(close, true);
  ArraySetAsSeries(tick_volume, true);

  int toSkip = 1;
  for (int pos = MathMin(bars_limit,
                         rates_total - 1 - MathMax(prev_calculated, toSkip));
       pos >= 0 && !IsStopped(); --pos) {
    double upValue =
        iCustom(_Symbol, _Period, "TMA+CG_mladen_NRP", false, false, HalfLength,
                20, BandsDeviations, Price, MODE_SMA, 1, 3, Interpolate, false,
                false, false, 3, pos);

    int colorIndex = out.GetColorIndex(pos + 1);
    if (upValue != EMPTY_VALUE) {
      colorIndex = 0;
    }
    double downValue =
        iCustom(_Symbol, _Period, "TMA+CG_mladen_NRP", false, false, HalfLength,
                20, BandsDeviations, Price, MODE_SMA, 1, 3, Interpolate, false,
                false, false, 4, pos);

    if (downValue != EMPTY_VALUE) {
      colorIndex = 1;
    }
    out.Set(1, pos, colorIndex);
  }

  ArraySetAsSeries(time, timeSeries);
  ArraySetAsSeries(open, openSeries);
  ArraySetAsSeries(high, highSeries);
  ArraySetAsSeries(low, lowSeries);
  ArraySetAsSeries(close, closeSeries);
  ArraySetAsSeries(tick_volume, tickVolumeSeries);
  return rates_total;
}
