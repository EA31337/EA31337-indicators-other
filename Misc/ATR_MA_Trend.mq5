#property copyright ""
#property link ""
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//+----------------------------------------------+
//|  Bullish indicator rendering options    |
//+----------------------------------------------+
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_style1  STYLE_DASHDOTDOT
#property indicator_width1  2
#property indicator_label1  "Upper TrendValue"
//+----------------------------------------------+
//|  Bearish indicator rendering options   |
//+----------------------------------------------+
#property indicator_type2   DRAW_LINE
#property indicator_color2  MediumVioletRed
#property indicator_style2  STYLE_DASHDOTDOT
#property indicator_width2  2
#property indicator_label2  "Lower TrendValue"
//+----------------------------------------------+
//|  Bullish indicator rendering options      |
//+----------------------------------------------+
#property indicator_type3   DRAW_ARROW
#property indicator_color3  DeepSkyBlue
#property indicator_width3  4
#property indicator_label3  "Buy TrendValue"
//+----------------------------------------------+
//|  Bearish indicator rendering options  |
//+----------------------------------------------+
#property indicator_type4   DRAW_ARROW
#property indicator_color4  Red
#property indicator_width4  4
#property indicator_label4  "Sell TrendValue"
//+----------------------------------------------+
//| Indicator Input             |
//+----------------------------------------------+
input int    period=13;
input double shiftPercent=0;
input int    ATRPeriod=15;
input double ATRSensitivity=1.5;
input int    Shift=0;
//+----------------------------------------------+
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
int ATR_Handle,HMA_Handle,LMA_Handle;
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get ATR indicator handle");
      return(1);
     }

   HMA_Handle=iMA(NULL,0,period,0,MODE_LWMA,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get HMA indicator handle");
      return(1);
     }

   LMA_Handle=iMA(NULL,0,period,0,MODE_LWMA,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get LMA indicator handle");
      return(1);
     }

   min_rates_total=ATRPeriod+period;

   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(ExtMapBufferUp,true);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(ExtMapBufferDown,true);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(ExtMapBufferUp1,true);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(2,PLOT_ARROW,117);

   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(ExtMapBufferDown1,true);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(3,PLOT_ARROW,117);

   string shortname;
   StringConcatenate(shortname,"TrendValue(",period,", ",shiftPercent,", ",ATRPeriod,", ",ATRSensitivity,", ",Shift,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double& high[],
                const double& low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);

   double ATR[],HMA[],LMA[],atr;
   double highMoving0,lowMoving0;
   int limit,to_copy,bar,trend,maxbar;
   static double highMoving1,lowMoving1;
   static int trend_;

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);

   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      limit=rates_total-min_rates_total-1;
      trend_=0;
     }
   else
     {
      limit=rates_total-prev_calculated;
     }

   maxbar=rates_total-min_rates_total-1;

   to_copy=limit+1;
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(0);
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(0);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(0);

   trend=trend_;

   for(bar=limit; bar>=0; bar--)
     {
      ExtMapBufferUp[bar]=NULL;
      ExtMapBufferDown[bar]=NULL;
      ExtMapBufferUp1[bar]=NULL;
      ExtMapBufferDown1[bar]=NULL;

      atr=ATR[bar]*ATRSensitivity;
      highMoving0= HMA[bar] *(1+shiftPercent/100)+atr;
      lowMoving0 = LMA[bar] *(1-shiftPercent/100)-atr;

      if(bar>maxbar)
        {
         lowMoving1=lowMoving0;
         highMoving1=highMoving0;
         continue;
        }

      if(close[bar] > highMoving1)trend = +1;
      if(close[bar] < lowMoving1) trend = -1;

      if(trend>0)
        {
         lowMoving0=MathMax(lowMoving0,lowMoving1);
         ExtMapBufferUp[bar]=lowMoving0;
        }

      if(trend<0)
        {
         highMoving0=MathMin(highMoving0,highMoving1);
         ExtMapBufferDown[bar]=highMoving0;
        }

      if(ExtMapBufferUp[bar+1]==NULL && ExtMapBufferUp[bar]!=NULL) ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];
      if(ExtMapBufferDown[bar+1]==NULL && ExtMapBufferDown[bar]!=NULL) ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];

      if(bar>0)
        {
         lowMoving1=lowMoving0;
         highMoving1=highMoving0;
         trend_=trend;
        }
     }
   return(rates_total);
  }
