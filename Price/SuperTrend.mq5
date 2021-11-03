//+------------------------------------------------------------------+
//|                                                   SuperTrend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Olivier Seban's SuperTrend indicator"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot ST
#property indicator_label1  "SuperTrend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  14;         // Period
input uint              InpShift       =  20;         // Shift
input ENUM_INPUT_YES_NO InpUseFilter   =  INPUT_YES;  // Use filter
//--- indicator buffers
double         BufferST[];
double         BufferColors[];
double         BufferFlag[];
double         BufferCCI[];
//--- global variables
double         shift;
int            period_cci;
int            handle_cci;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriod<2 ? 2 : InpPeriod);
   shift=InpShift*Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferST,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferFlag,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferCCI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SuperTrend ("+(string)period_cci+","+(string)InpShift+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferST,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFlag,true);
   ArraySetAsSeries(BufferCCI,true);
//--- create cci handle
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferST,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferFlag,0);
      ArrayInitialize(BufferCCI,0);
     }

//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   ResetLastError();
   int copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double CCI=BufferCCI[i];
      BufferST[i]=BufferST[i+1];
      BufferFlag[i]=BufferFlag[i+1];
      BufferColors[i]=2;

      if(CCI>0 && BufferFlag[i]<=0)
        {
         BufferFlag[i]=1;
         BufferST[i]=low[i]-shift;
        }

      if(CCI<0 && BufferFlag[i]>=0)
        {
         BufferFlag[i]=-1;
         BufferST[i]=high[i]+shift;
        }

      BufferST[i]=
        (
         BufferFlag[i]>0 && low[i]-shift>BufferST[i+1] ? low[i]-shift :
         BufferFlag[i]<0 && high[i]+shift<BufferST[i+1] ? high[i]+shift :
         BufferST[i]
        );

      if(InpUseFilter)
        {
         if(BufferFlag[i]>0 && BufferST[i]>BufferST[i+1])
           {
            if(close[i]<open[i])
               BufferST[i]=BufferST[i+1];
            if(high[i]<high[i+1])
               BufferST[i]=BufferST[i+1];
           }
         if(BufferFlag[i]<0 && BufferST[i]<BufferST[i+1])
           {
            if(close[i]>open[i])
               BufferST[i]=BufferST[i+1];
            if(low[i]>low[i+1])
               BufferST[i]=BufferST[i+1];
           }
        }

      if(close[i]>BufferST[i])
         BufferColors[i]=0;
      else
         BufferColors[i]=1;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
