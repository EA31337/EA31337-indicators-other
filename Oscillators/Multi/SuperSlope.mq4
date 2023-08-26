//+------------------------------------------------------------------+
//|                                                   SuperSlope.mq4 |
//|                                  Copyright 2016, Paul Geirnaerdt |
//|                                           http://www.delabron.nl |
//+------------------------------------------------------------------+
//09/05/2016 arrows and mtf currency table by gprince66 SHF
//09/18/2016 Combined Baluda's and Gary's work into one project. Colors updated by Nanningbob
//10/10/2016 SS now works on all pairs, including exotics. by VirtualFM SHF
#property copyright "Copyright 2016, Paul Geirnaerdt"
#property link      "http://www.delabron.nl"
#property indicator_separate_window
#property indicator_buffers 2
#property strict

#define version        "v2.2"
#define CURRENCYCOUNT  9

extern string  gen                  = "----General Inputs----"; //----
extern int     maxBars              = 0; //maxBars>0 turns off WindowFirstVisibleBar()
extern string  nonPropFont          = "Lucida Console";
extern string  spac751              = "----"; //----
extern bool    autoTimeFrame        = false;
extern string  ind_tf               = "timeFrame M1,M5,M15,M30,H1,H4,D1,W1,MN"; //----
extern string  timeFrame            = "D1"; //timeFrame: CSS & left column
extern string  extraTimeFrame       = "W1"; //extraTimeFrame: center column
extern string  extraTimeFrame2      = "MN"; //extraTimeFrame2: right column
extern int     NoOfTimeFrames       = 3;    //NoOfTimeFrames: num of TF to display
extern string  spac756              = "---- Slope Inputs ----"; //----
extern double  differenceThreshold  = 0.0;
extern double  levelCrossValue      = 2.0;
extern int     SlopeMAPeriod        = 7;
extern int     SlopeATRPeriod       = 50;
extern string  spac754              = "---- Send Alerts ----"; //----
extern bool    sendCrossAlerts      = true;
extern bool    sendLevelCrossAlerts = true;
extern bool    sendExitCrossAlerts  = true;
extern bool    sendMTFAgreeAlerts   = true; //sendMTFAgreeAlerts: timeFrame regulates alerts
extern string  spac754a             = "----"; //----
extern bool    PopupAlert           = true;
extern bool    EmailAlert           = true;
extern bool    PushAlert            = true;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int    leftBarPrev=0, rightBarPrev=0;
bool   _BrokerHasSundayCandles;
int    userNoOfTimeFrames;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  disp                     = "----Display Inputs----"; //----
extern int     displayTextSize          = 10;
extern int     horizontalOffset         = 10;
extern int     verticalOffset           = 5;
extern int     horizontalShift          = 20; //horizontalShift: columns
extern int     verticalShift            = 15; //verticalShift: rows
extern string  spc1134                  = "---- Multiple Indis ----"; //----
extern bool    showSlopeValues          = true;
extern bool    showCurrencyLines        = true;
extern bool    showLevelCrossLines      = true;
extern bool    showBackgroundColor      = true;
extern bool    showDifferenceThreshold  = true;
extern color   differenceThresholdColor = clrYellow;
extern string  spac8574                 = "----"; //----
extern int     levelCrossLineSize       = 2;
extern int     backgroundLineWidth      = 8; //backgroundLineWidth: 80% zoom ~ 14 line width
///////////////////////////////////////////////////////////////////////////////////////////////////

extern string  gen2                = "----Arrow Display----"; //----
extern bool    showArrows          = true;
extern color   BuyArrowColor       = clrDarkGreen;
extern int     BuyArrowFontSize    = 14;
extern color   SellArrowColor      = clrMaroon;
extern int     SellArrowFontSize   = 14;
extern string  spac456             = "----"; //----
extern bool    showSignalLine      = true;
extern color   SignalLineBuyColor  = clrDarkGreen;
extern color   SignalLineSellColor = clrDeepPink;
extern int     SignalLineSize      = 1;
/////////////////////////////////////////////////////////////////////////////////////////
int    ATRPeriodArrows=20;
double ATRMultiplierArrows=1.0;
uchar  BuyArrowStyle=225;
uchar  SellArrowStyle=226;
bool   TradeLong=false, TradeShort=false;
bool   BuyArrowActive=false, SellArrowActive=false;
bool   OnlyDrawArrowsOnNewBar=true;
/////////////////////////////////////////////////////////////////////////////////////////

extern string  rede              = "---- Read Delay ----"; //----
extern bool    EveryTickMode     = true;
extern bool    ReadEveryNewBar   = false; //ReadEveryNewBar: Reads every new bar even if ReadEveryXSeconds hasn't expired
extern int     ReadEveryXSeconds = 5; //ReadEveryXSeconds: Set EveryTickMode to false
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool     IsItNewBar=false, userEveryTickMode, userReadEveryNewBar;
datetime lastBarTime = -1, nextReadTime = -1, lastBarTime2 = -1;
int      userReadEveryXSeconds;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  colour="----Colo(u)r inputs----"; //----
extern color   Color_USD         = clrRed;
extern color   Color_EUR         = clrDeepSkyBlue;
extern color   Color_GBP         = clrRoyalBlue;
extern color   Color_CHF         = clrPaleTurquoise;
extern color   Color_JPY         = clrGold;
extern color   Color_AUD         = clrDarkOrange;
extern color   Color_CAD         = clrPink;
extern color   Color_NZD         = clrTan;
extern color   Color_default     = clrWhite;
extern int     line_width_USD    = 3;
extern int     line_style_USD    = 0;
extern int     line_width_EUR    = 3;
extern int     line_style_EUR    = 0;
extern int     line_width_GBP    = 3;
extern int     line_style_GBP    = 0;
extern int     line_width_JPY    = 3;
extern int     line_style_JPY    = 0;
extern int     line_width_AUD    = 3;
extern int     line_style_AUD    = 0;
extern int     line_width_CAD    = 3;
extern int     line_style_CAD    = 0;
extern int     line_width_NZD    = 3;
extern int     line_style_NZD    = 0;
extern int     line_width_CHF    = 3;
extern int     line_style_CHF    = 0;
extern color   colorWeakCross    = clrGold;
extern color   colorNormalCross  = clrGold;
extern color   colorStrongCross  = clrGold;
extern color   colorDifferenceUp = 0x303000;
extern color   colorDifferenceDn = 0x000030;
extern color   colorDifferenceLo = 0x005454;
extern color   colorTimeframe    = clrWhite;
extern color   colorLevelHigh    = clrLimeGreen;
extern color   colorLevelLow     = clrCrimson;
/////////////////////////////////////////////////////////////////////////////////////////////////

//global variables
string   indicatorName="SuperSlope";
string   shortName, almostUniqueIndex;
int      windex, size;
string   ObjSuff, ObjSuff2;
int      userTimeFrame;
int      userExtraTimeFrame;
int      userExtraTimeFrame2;
bool     IsInit=false;
string   objectName="";
double   Slope_2, Slope_3;

//bufffers
double   Slope1[];
double   Slope2[];

//currency variables
string   currencyNames[CURRENCYCOUNT]={ "USD","EUR","GBP","JPY","AUD","CAD","NZD","CHF","" };
int      line_width[CURRENCYCOUNT];
int      line_style[CURRENCYCOUNT];
color    currencyColors[CURRENCYCOUNT];
int      index, index2;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   int i;
   IsInit=true;

   initTimeFrames();

   //unique indicator name
   string now=string(TimeCurrent());
   almostUniqueIndex=StringSubstrOld(now,StringLen(now)-3)+IntegerToString(WindowsTotal())+IntegerToString(WindowOnDropped());
   shortName=indicatorName+" - "+version+" - id"+almostUniqueIndex;
   IndicatorShortName(shortName);
   windex=WindowFind(shortName);

   ObjSuff="_"+almostUniqueIndex+"_BSS";
   ObjSuff2="_"+almostUniqueIndex+"_objdel";

   //----

   currencyColors[0]=Color_USD;
   line_width[0]=line_width_USD;
   line_style[0]=line_style_USD;

   currencyColors[1]=Color_EUR;
   line_width[1]=line_width_EUR;
   line_style[1]=line_style_EUR;

   currencyColors[2]=Color_GBP;
   line_width[2]=line_width_GBP;
   line_style[2]=line_style_GBP;

   currencyColors[3]=Color_JPY;
   line_width[3]=line_width_JPY;
   line_style[3]=line_style_JPY;

   currencyColors[4]=Color_AUD;
   line_width[4]=line_width_AUD;
   line_style[4]=line_style_AUD;

   currencyColors[5]=Color_CAD;
   line_width[5]=line_width_CAD;
   line_style[5]=line_style_CAD;

   currencyColors[6]=Color_NZD;
   line_width[6]=line_width_NZD;
   line_style[6]=line_style_NZD;

   currencyColors[7]=Color_CHF;
   line_width[7]=line_width_CHF;
   line_style[7]=line_style_CHF;

   currencyColors[8]=Color_default;
   line_width[8]=line_width_USD;
   line_style[8]=line_style_USD;

   //----

   if(CSS_Available(StringSubstrOld(Symbol(),0,3)) && CSS_Available(StringSubstrOld(Symbol(),3,3)))
   {
      index=getCurrencyIndex(StringSubstrOld(Symbol(),0,3));
      index2=getCurrencyIndex(StringSubstrOld(Symbol(),3,3));
   }
   else
   {
      index=8;
      index2=index;
   }

   SetIndexBuffer( 0, Slope1 );
   SetIndexLabel(0, currencyNames[index]);

   SetIndexBuffer( 1, Slope2 );
   SetIndexLabel(1, currencyNames[index2]);

   //display currency lines
   if(showCurrencyLines)
   {
      SetIndexStyle(0,DRAW_LINE,line_style[index],line_width[index],currencyColors[index]);
      SetIndexStyle(1,DRAW_LINE,line_style[index2],line_width[index2],currencyColors[index2]);
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
   }

   //----

   _BrokerHasSundayCandles = false;
   for ( i = 0; i < 8; i++ )
   {
      if ( TimeDayOfWeek( iTime( NULL, PERIOD_D1, i ) ) == 0 )
      {
         _BrokerHasSundayCandles = true;
         break;
      }
   }

   //input variables
   userNoOfTimeFrames = NoOfTimeFrames;
   userEveryTickMode = EveryTickMode;
   userReadEveryNewBar = ReadEveryNewBar;
   userReadEveryXSeconds = ReadEveryXSeconds;

   if(userNoOfTimeFrames > 3) userNoOfTimeFrames = 3;
   if(userNoOfTimeFrames < 1) userNoOfTimeFrames = 1;

   return(INIT_SUCCEEDED);

}//OnInit()

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //Remove objects that belong to this indicator
   //Add suffix "_xxx" to object name
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      if(StringFind(ObjectName(i),ObjSuff,0)>0)
      {
         ObjectDelete(ObjectName(i));
      }
   }

}//OnDeinit(const int reason)

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
   //variables
   int      i=0, j=0, leftBar=0, rightBar=0, bar=0;
   double   ATR=0, ArrowHigh=0, ArrowLow=0;
   datetime myTime=0;

   //read delay
   if(IsNewReadTime())
   {
      IsItNewBar = IsNewBar();

      //maxBars>0 turns off WindowFirstVisibleBar()
      //maxBars>300 ~ visual backtesting only
      if(maxBars > 0)
      {
         //turn off WindowFirstVisibleBar()
         leftBar=MathMin(maxBars,Bars-10);
         rightBar = 0;

         //prevent mt4 crash
         if(maxBars > 300)
         {
            userEveryTickMode = false;
            userReadEveryNewBar = false;
            userReadEveryXSeconds = 86400;
         }
      }
      else
      {
         //loop only what's visible on chart
         leftBar = WindowFirstVisibleBar();
         rightBar = leftBar - WindowBarsPerChart();
         if(rightBar < 0) rightBar = 0;
      }

      //////////////////////////////////////////////////////////////////////


      //main loop
      for(i=leftBar; i>=rightBar; i--)
      {
         //ignore last 50 bars
         if (i > rates_total - 50) continue;

         //skip first 'i'
         if(i < leftBar)
         {
            //arrow spacing
            ATR = iATR(_Symbol,_Period,ATRPeriodArrows,i);
            ArrowHigh = iHigh(_Symbol,_Period,i) + ATR*ATRMultiplierArrows;
            ArrowLow = iLow(_Symbol,_Period,i) - ATR*ATRMultiplierArrows;

            //get slope ~ must use chart's Time[i] for css lines to display properly
            bar=iBarShift(NULL,userTimeFrame,Time[i]);
            Slope1[i] = GetSlope(userTimeFrame, SlopeMAPeriod, SlopeATRPeriod, bar);
            Slope2[i] = -Slope1[i];

            //Set trade direction
            TradeLong=false; TradeShort=false;
            if(Slope1[i] > differenceThreshold*0.5)
               TradeLong=true;
            if(Slope1[i] < -differenceThreshold*0.5)
               TradeShort=true;

            ////////////////////////////////////////////////////////////////////////////////


            if(i==rightBar)
            {
               //get slope for extra time frames
               if(userNoOfTimeFrames > 1 || (sendMTFAgreeAlerts && rightBar == 0))
                  Slope_2 = GetSlope(userExtraTimeFrame, SlopeMAPeriod, SlopeATRPeriod, rightBar);

               if(userNoOfTimeFrames > 2 || (sendMTFAgreeAlerts && rightBar == 0))
                  Slope_3 = GetSlope(userExtraTimeFrame2, SlopeMAPeriod, SlopeATRPeriod, rightBar);


               //Show ordered tables
               if(userNoOfTimeFrames == 1)
               {
                  ShowCurrencyTable(userTimeFrame, 1, rightBar); //css & left column
                  ShowCurrencyTable(userTimeFrame, 4, rightBar); //threshold
               }
               else if(userNoOfTimeFrames == 2)
               {
                  ShowCurrencyTable(userTimeFrame, 1, rightBar);
                  ShowCurrencyTable(userExtraTimeFrame, 2, rightBar); //center column
                  ShowCurrencyTable(userTimeFrame, 4, rightBar);
               }
               else if(userNoOfTimeFrames == 3)
               {
                  ShowCurrencyTable(userTimeFrame, 1, rightBar);
                  ShowCurrencyTable(userExtraTimeFrame, 2, rightBar);
                  ShowCurrencyTable(userExtraTimeFrame2, 3, rightBar); //right column
                  ShowCurrencyTable(userTimeFrame, 4, rightBar);
               }

            }//if(i==rightBar)

            ///////////////////////////////////////////////////////////////////////////////////////////


            //delete arrows if leftBar changes or viewable bars change
            if(!IsInit && i==leftBar-1)
            {
               if(leftBar != leftBarPrev || leftBar-rightBar != leftBarPrev-rightBarPrev)
               {
                  //Remove objects
                  for(j=ObjectsTotal()-1;j>=0;j--)
                  {
                     if(StringFind(ObjectName(j),ObjSuff2,0) > 0)
                     {
                        ObjectDelete(ObjectName(j));
                     }
                  }

                  //css buffers
                  double slopeTemp=Slope1[0];
                  ArrayInitialize(Slope1,EMPTY_VALUE);
                  ArrayInitialize(Slope2,EMPTY_VALUE);
                  Slope1[0] = slopeTemp;
                  Slope2[0] = -slopeTemp;

               }//if(leftBar != leftBarPrev || leftBar-rightBar != leftBarPrev-rightBarPrev)

            }//if(!IsInit && i==leftBar-1)

            /////////////////////////////////////////////////////////////////////////////////////


            //Create background object
            if(showBackgroundColor)
            {
               objectName=almostUniqueIndex+"_diff_"+TimeToString(Time[i])+ObjSuff+ObjSuff2;
               if(ObjectFind(objectName)==-1)
               {
                  if(ObjectCreate(objectName,OBJ_VLINE,windex,Time[i],0))
                  {
                     ObjectSet(objectName,OBJPROP_BACK,true);
                     ObjectSet(objectName,OBJPROP_HIDDEN,true);
                     ObjectSet(objectName,OBJPROP_WIDTH,backgroundLineWidth);
                  }
               }

               //Draw background color
               if(MathAbs(Slope1[i])>differenceThreshold*0.5)
               {
                  if(TradeLong)
                     ObjectSet(objectName,OBJPROP_COLOR,colorDifferenceUp);
                  if(TradeShort)
                     ObjectSet(objectName,OBJPROP_COLOR,colorDifferenceDn);
               }
               else
               {
                  //Below threshold
                  ObjectSet(objectName,OBJPROP_COLOR,colorDifferenceLo);
               }

            }//if(showBackgroundColor)

            //////////////////////////////////////////////////////////////////////////////////////


            //avoid trivial crosses
            bool OkToDrawArrows = false;
            if(OnlyDrawArrowsOnNewBar)
               if(IsItNewBar) OkToDrawArrows=true;
            else
               OkToDrawArrows=true;

            //draw arrows
            if(showArrows && OkToDrawArrows)
            {
               //Buy
               if(TradeLong && !BuyArrowActive)
               {
                  objectName = "Buy Arrow "+IntegerToString((int)time[i])+ObjSuff+ObjSuff2;
                  if(ObjectFind(objectName)==-1)
                  {
                     TextCreate(objectName, time[i], ArrowLow, CharToString(BuyArrowStyle), BuyArrowColor, ANCHOR_LOWER, "wingdings", BuyArrowFontSize);
                  }

                  //signal line
                  if(showSignalLine && i==0)
                  {
                     objectName = "Buy Signal Line "+IntegerToString((int)time[i])+ObjSuff;
                     if(ObjectFind(objectName)==-1)
                     {
                        if(ObjectCreate(objectName,OBJ_TREND,0,time[i+1],close[0],time[i]+Period()*60,close[0]))
                        {
                           ObjectSet(objectName,OBJPROP_BACK,true);
                           ObjectSet(objectName,OBJPROP_WIDTH,SignalLineSize);
                           ObjectSet(objectName,OBJPROP_COLOR,SignalLineBuyColor);
                           ObjectSet(objectName,OBJPROP_RAY,false);
                           ObjectSet(objectName,OBJPROP_HIDDEN,true);
                        }
                     }
                  }

                  BuyArrowActive=true;
                  SellArrowActive=false;

               }//if(TradeLong && !BuyArrowActive)

               //Sell
               if(TradeShort && !SellArrowActive)
               {
                  objectName = "Sell Arrow "+IntegerToString((int)time[i])+ObjSuff+ObjSuff2;
                  if(ObjectFind(objectName)==-1)
                  {
                     TextCreate(objectName, time[i], ArrowHigh, CharToString(SellArrowStyle), SellArrowColor, ANCHOR_UPPER, "wingdings", SellArrowFontSize);
                  }

                  //signal line
                  if(showSignalLine && i==0)
                  {
                     objectName = "Sell Signal Line "+IntegerToString((int)time[i])+ObjSuff;
                     if(ObjectFind(objectName)==-1)
                     {
                        if(ObjectCreate(objectName,OBJ_TREND,0,time[i+1],close[0],time[i]+Period()*60,close[0]))
                        {
                           ObjectSet(objectName,OBJPROP_BACK,true);
                           ObjectSet(objectName,OBJPROP_WIDTH,SignalLineSize);
                           ObjectSet(objectName,OBJPROP_COLOR,SignalLineSellColor);
                           ObjectSet(objectName,OBJPROP_RAY,false);
                           ObjectSet(objectName,OBJPROP_HIDDEN,true);
                        }
                     }
                  }

                  BuyArrowActive=false;
                  SellArrowActive=true;

               }//if(TradeShort && !SellArrowActive)

               //difference Lo
               if(!TradeLong && !TradeShort)
               {
                  BuyArrowActive=false;
                  SellArrowActive=false;
               }

            }//if(showArrows && OkToDrawArrows)

         }//if(i < leftBar)

      }//for(i=leftBar; i>=rightBar; i--)


      //Draw 0.2 & -0.2 green/red lines
      if(showLevelCrossLines)
      {
         objectName=almostUniqueIndex+"_high"+ObjSuff;
         ObjectDelete(objectName);
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_TREND,windex,Time[leftBar],levelCrossValue,Time[rightBar],levelCrossValue))
            {
               ObjectSet(objectName,OBJPROP_BACK,true);
               ObjectSet(objectName,OBJPROP_WIDTH,levelCrossLineSize);
               ObjectSet(objectName,OBJPROP_COLOR,colorLevelHigh);
               ObjectSet(objectName,OBJPROP_RAY,false);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         objectName=almostUniqueIndex+"_low"+ObjSuff;
         ObjectDelete(objectName);
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_TREND,windex,Time[leftBar],-levelCrossValue,Time[rightBar],-levelCrossValue))
            {
               ObjectSet(objectName,OBJPROP_BACK,true);
               ObjectSet(objectName,OBJPROP_WIDTH,levelCrossLineSize);
               ObjectSet(objectName,OBJPROP_COLOR,colorLevelLow);
               ObjectSet(objectName,OBJPROP_RAY,false);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
      }

   }//if(IsNewReadTime())

   //no alerts on initialization
   IsInit=false;

   //delete stuff if new leftBar
   leftBarPrev=leftBar;
   rightBarPrev=rightBar;

   return(rates_total);

}//OnCalculate()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewReadTime()
{
   bool NewReadTime = false;
   bool IsReadEveryNewBar = false;

   if(userEveryTickMode)
   {
      NewReadTime = true;
   }
   else
   {
     if(userReadEveryNewBar)
      {
        if(lastBarTime < iTime(_Symbol, _Period, 0))
       {
          lastBarTime = iTime(_Symbol, _Period, 0) + 1;
            IsReadEveryNewBar = true;
       }
      }
      else
      {
         IsReadEveryNewBar = true;
      }

     if(nextReadTime <= TimeCurrent() || IsReadEveryNewBar)
      {
         nextReadTime = TimeCurrent() + userReadEveryXSeconds;
         NewReadTime = true;
      }
   }

   return(NewReadTime);

}//IsNewReadTime()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   //many thanks renexxxx
   //+1 deals with multiple ticks per second

   bool newBar = false;

   if ( lastBarTime2 < iTime( _Symbol, _Period, 0 ) ) {
      lastBarTime2 = iTime( _Symbol, _Period, 0 ) + 1;
      newBar = true;
   }
   return(newBar);

}//IsNewBar()

//+------------------------------------------------------------------+
//| getSlope()                                                       |
//+------------------------------------------------------------------+
double GetSlope( int tf, int maperiod, int atrperiod, int pShift )
{
   double dblTma, dblPrev;
   int shiftWithoutSunday = pShift;
   if ( _BrokerHasSundayCandles && PERIOD_CURRENT == PERIOD_D1 )
   {
      if ( TimeDayOfWeek( iTime( NULL, PERIOD_D1, pShift ) ) == 0  ) shiftWithoutSunday++;
   }

   double atr = iATR( NULL, tf, atrperiod, shiftWithoutSunday + 10 ) / 10;
   double result = 0.0;
   if ( atr != 0 )
   {
      dblTma = iMA( NULL, tf, maperiod, 0, MODE_LWMA, PRICE_CLOSE, shiftWithoutSunday );
      dblPrev = ( iMA( NULL, tf, maperiod, 0, MODE_LWMA, PRICE_CLOSE, shiftWithoutSunday + 1 ) * 231 + iClose( NULL, tf, shiftWithoutSunday ) * 20 ) / 251;

      result = ( dblTma - dblPrev ) / atr;
   }

   return ( result );

}//GetSlope(}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fireAlerts(string sMsg)
{
   if(PopupAlert)
      Alert(sMsg);
   if(EmailAlert)
      SendMail("CSS Alert "+"",sMsg);
   if(PushAlert)
      SendNotification(sMsg);

}//fireAlerts()

//+------------------------------------------------------------------+
// StrToTF(string str)                                               |
//+------------------------------------------------------------------+
// Converts a timeframe string to its MT4-numeric value
// Usage:   int x=StrToTF("M15")   returns x=15
int StrToTF(string str)
{
  str = StringUpper(str);
  str = StringTrimLeft(str);
  str = StringTrimRight(str);

  if (str == "M1")   return(1);
  if (str == "M5")   return(5);
  if (str == "M15")  return(15);
  if (str == "M30")  return(30);
  if (str == "H1")   return(60);
  if (str == "H4")   return(240);
  if (str == "D1")   return(1440);
  if (str == "W1")   return(10080);
  if (str == "MN" || str == "MN1")  return(43200);

  return(0);

} //End StrToTF(string str)

//+------------------------------------------------------------------+
//| StringUpper(string str)                                           |
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
string StringUpper(string str)
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);

}//StringUpper(string str)

//+------------------------------------------------------------------+
//| TF to String                                                     |
//+------------------------------------------------------------------+
string TFToString(int tf)
{
   switch(tf) {
      case 1: return("M1"); break;
    case 5: return("M5"); break;
    case 15: return("M15"); break;
    case 30: return("M30"); break;
    case 60: return("H1"); break;
    case 240: return("H4"); break;
    case 1440: return("D1"); break;
    case 10080: return("W1"); break;
    case 43200: return("MN"); break;
    default: return(TFToString(_Period));
  }

  return(TFToString(_Period));

}//TFToString(int tf)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringSubstrOld(string x, int a, int b=-1)
{
   if(a<0) a=0; //stop odd behaviour
   if(b<=0) b=-1; //new MQL4 EOL flag

   return StringSubstr(x,a,b);

}//StringSubstrOld()

//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
void TextCreate(const string            pName = "Text",             // object name
                datetime                time = 0,                   // anchor point time
                double                  price = 0,                  // anchor point price
                const string            text = "Text",              // the text itself
                const color             clr = clrRed,               // color
                const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type
                const string            font = "Wingdings",         // font
                const int               font_size = 14,             // font size
                const double            angle = 0.0,                // text slope
                const bool              back = true,                // in the background
                const bool              selection = false,          // highlight to move
                const bool              hidden = true,              // hidden in the object list
                const long              z_order = 0
               )
{
   long chart_ID = ChartID();
   string name = pName;

   if ( ObjectFind( chart_ID, name ) < 0 )
   {
      if ( !ObjectCreate( chart_ID, name, OBJ_TEXT, 0, time, price ) )
      {
         Print(__FUNCTION__, ": failed to create \"Text\" object! Error code = ", GetLastError() );
         return;
      }
   }

   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

}//TextCreate()

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initTimeFrames()
{
   if(!autoTimeFrame)
   {
      userTimeFrame = StrToTF(timeFrame); //css & left column
      userExtraTimeFrame = StrToTF(extraTimeFrame); //center column
      userExtraTimeFrame2 = StrToTF(extraTimeFrame2); //right column
   }
   else
   {
      //Auto Time Frame

      //userTimeFrame = css & left column = chart tf
      //userExtraTimeFrame = center column = higher tf
      //userExtraTimeFrame2 = right column = lower tf

      //----

      //Chart TF ~ css & left column
      userTimeFrame=_Period;

      //Higher TF ~ center column
      if( userTimeFrame == PERIOD_M1 ) userExtraTimeFrame = PERIOD_M5;
      else if( userTimeFrame == PERIOD_M5 )  userExtraTimeFrame = PERIOD_M15;
      else if( userTimeFrame == PERIOD_M15 ) userExtraTimeFrame = PERIOD_M30;
      else if( userTimeFrame == PERIOD_M30 ) userExtraTimeFrame = PERIOD_H1;
      else if( userTimeFrame == PERIOD_H1 )  userExtraTimeFrame = PERIOD_H4;
      else if( userTimeFrame == PERIOD_H4 )  userExtraTimeFrame = PERIOD_D1;
      else if( userTimeFrame == PERIOD_D1 )  userExtraTimeFrame = PERIOD_W1;
      else if( userTimeFrame == PERIOD_W1 )  userExtraTimeFrame = PERIOD_MN1;
      else if( userTimeFrame == PERIOD_MN1 )  userExtraTimeFrame = PERIOD_MN1;

      //Lower TF ~ right column
      if( userTimeFrame == PERIOD_M1 ) userExtraTimeFrame2 = PERIOD_M1;
      else if( userTimeFrame == PERIOD_M5 )  userExtraTimeFrame2 = PERIOD_M1;
      else if( userTimeFrame == PERIOD_M15 ) userExtraTimeFrame2 = PERIOD_M5;
      else if( userTimeFrame == PERIOD_M30 ) userExtraTimeFrame2 = PERIOD_M15;
      else if( userTimeFrame == PERIOD_H1 )  userExtraTimeFrame2 = PERIOD_M30;
      else if( userTimeFrame == PERIOD_H4 )  userExtraTimeFrame2 = PERIOD_H1;
      else if( userTimeFrame == PERIOD_D1 )  userExtraTimeFrame2 = PERIOD_H4;
      else if( userTimeFrame == PERIOD_W1 )  userExtraTimeFrame2 = PERIOD_D1;
      else if( userTimeFrame == PERIOD_MN1 )  userExtraTimeFrame2 = PERIOD_W1;
   }

}//initTimeFrames()

//+------------------------------------------------------------------+
//| ShowCurrencyTable()                                              |
//+------------------------------------------------------------------+
void ShowCurrencyTable(int tf, int column, int rightBar2)
{
   int    i=0;
   string showText;

   //get diff digits for display
   int diffdigits=GetDecimalValue(differenceThreshold);

   //no alerts on initialization or visual backtests
   bool OkToSendAlerts = (!IsInit && column == 1 && rightBar2 == 0 && IsItNewBar);

   if(showSlopeValues)
   {
      //first time frame
      if(column == 1)
      {
         //header
         objectName=almostUniqueIndex+"_css_obj_column1_tf"+ObjSuff;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*6);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,TFToString(userTimeFrame),displayTextSize,nonPropFont,colorTimeframe);

         //value
         objectName=almostUniqueIndex+"_css_obj_column1_value1"+ObjSuff;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*6);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*1.5);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText=DoubleToStr(Slope1[rightBar2],2);
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index]);

      }//if(column == 1)

      //second time frame
      if(column == 2)
      {
         //header
         objectName=almostUniqueIndex+"_css_obj_column2_tf"+ObjSuff;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10+horizontalShift*3);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,TFToString(userExtraTimeFrame),displayTextSize,nonPropFont,colorTimeframe);

         //value
         objectName=almostUniqueIndex+"_css_obj_column2_value1"+ObjSuff;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*3);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*1.5);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText=DoubleToStr(Slope_2,2);
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index]);

      }//if(column == 2)

      //third time frame
      if(column == 3)
      {
         //header
         objectName=almostUniqueIndex+"_css_obj_column3_tf"+ObjSuff;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+10);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         ObjectSetText(objectName,TFToString(userExtraTimeFrame2),displayTextSize,nonPropFont,colorTimeframe);

         //value
         objectName=almostUniqueIndex+"_css_obj_column3_value1"+ObjSuff;
         if(ObjectFind(objectName)==-1)
         {
            if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
            {
               ObjectSet(objectName,OBJPROP_CORNER,1);
               ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset);
               ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*1.5);
               ObjectSet(objectName,OBJPROP_HIDDEN,true);
            }
         }
         showText=DoubleToStr(Slope_3,2);
         ObjectSetText(objectName,showText,displayTextSize,nonPropFont,currencyColors[index]);

      }//if(column == 3)

   }//if(showSlopeValues)

   ///////////////////////////////////////////////////////////////////////////


   //threshold
   if(showDifferenceThreshold && column == 4)
   {
      objectName=almostUniqueIndex+"_css_obj_diff"+ObjSuff;
      if(ObjectFind(objectName)==-1)
      {
         if(ObjectCreate(objectName,OBJ_LABEL,windex,0,0))
         {
            ObjectSet(objectName,OBJPROP_CORNER,1);
            ObjectSet(objectName,OBJPROP_XDISTANCE,horizontalOffset+horizontalShift*0.25);
            ObjectSet(objectName,OBJPROP_YDISTANCE,verticalOffset+verticalShift*3.75);
            ObjectSet(objectName,OBJPROP_HIDDEN,true);
         }
      }
      showText=StringSubstrOld(_Symbol,0,6)+" thresh = "+DoubleToStr(differenceThreshold,diffdigits);
      ObjectSetText(objectName,showText,8,nonPropFont,differenceThresholdColor);

   }//if(showDifferenceThreshold && column == 4)

   ////////////////////////////////////////////////////////////////////////////////////////////


   //PopUp alert Stuff
   if(OkToSendAlerts)
   {
      if(sendCrossAlerts)
      {
         //curr1 crosses up curr2 (buy)
         if(Slope1[i+1] < differenceThreshold*0.5 && Slope1[i] > differenceThreshold*0.5)
            fireAlerts(_Symbol+" did a cross up  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

         //curr1 crosses down curr2 (sell)
         if(Slope1[i+1] > -differenceThreshold*0.5 && Slope1[i] < -differenceThreshold*0.5)
            fireAlerts(_Symbol+" did a cross down  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

      }//if(sendCrossAlerts)

      if(sendLevelCrossAlerts)
      {
         //curr1 crosses up levelCrossValue +2.0
         if(Slope1[i+1] < levelCrossValue && Slope1[i] > levelCrossValue)
            fireAlerts(_Symbol+" did a cross up "+DoubleToStr(levelCrossValue,2)+"  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

         //curr1 crosses down levelCrossValue -2.0
         if(Slope1[i+1] > -levelCrossValue && Slope1[i] < -levelCrossValue)
            fireAlerts(_Symbol+" did a cross down "+DoubleToStr(-levelCrossValue,2)+"  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

      }//if(sendLevelCrossAlerts)

      if(sendExitCrossAlerts)
      {
         //curr1 crosses down levelCrossValue +2.0 ~ exit buy
         if(Slope1[i+1] > levelCrossValue && Slope1[i] < levelCrossValue)
            fireAlerts(_Symbol+" did an 'exit buy' cross down "+DoubleToStr(levelCrossValue,2)+"  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

         //curr1 crosses up levelCrossValue -2.0 ~ exit sell
         if(Slope1[i+1] < -levelCrossValue && Slope1[i] > -levelCrossValue)
            fireAlerts(_Symbol+" did an 'exit sell' cross up "+DoubleToStr(-levelCrossValue,2)+"  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

      }//if(sendExitCrossAlerts)

      if(sendMTFAgreeAlerts)
      {
         //mtf agree and curr1 crosses up curr2 (buy)
         if(Slope_2 > differenceThreshold*0.5 && Slope_3 > differenceThreshold*0.5 && Slope1[i+1] < differenceThreshold*0.5 && Slope1[i] > differenceThreshold*0.5)
            fireAlerts(_Symbol+" MTF agree with a cross up  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

         //mtf agree and curr1 crosses down curr2 (sell)
         if(Slope_2 < -differenceThreshold*0.5 && Slope_3 < -differenceThreshold*0.5 && Slope1[i+1] > -differenceThreshold*0.5 && Slope1[i] < -differenceThreshold*0.5)
            fireAlerts(_Symbol+" MTF agree with a cross down  "+TFToString(tf)+" @"+DoubleToStr(Bid,_Digits)+"__"+TimeToStr(TimeCurrent(), TIME_MINUTES));

      }//if(sendMTFAgreeAlerts)

   }//if(OkToSendAlerts)

}//showCurrencyTable()

//+------------------------------------------------------------------+
//| getCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int getCurrencyIndex(string currency)
  {
   for(int i=0; i<CURRENCYCOUNT; i++)
     {
      if(currencyNames[i]==currency)
        {
         return(i);
        }
     }
   return (-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetDecimalValue(double val)
{
   //int diffdigits=GetDecimalValue(differenceThreshold);

   int    i=0, count=1, decval=0;
   int    slen=0, leftofdec=0;
   string str="";

   str = DoubleToStr(val);
   slen = StringLen(str);

   //digits left of decimal point
   leftofdec = StringFind(str, ".")+1; //add 1 for "."

   //count zeros from far right until number is reached (skip last digit)
   for(i=slen-1;i>=1;i--)
   {
      if(StringSubstrOld(str,i-1,1) == "0")
         count++;
      else
         break;
   }

   decval = slen - count - leftofdec;

   if(decval < 1) decval=1;

   return(decval);

}//GetDecimalValue(double val)

//+------------------------------------------------------------------+
//| CSS_Available()                                                  |
//+------------------------------------------------------------------+
bool CSS_Available(string symbol2check)
{
   for(int i = 0; i < ArraySize(currencyNames); i++){
      if(StringSubstr(symbol2check, 0, 3)== currencyNames[i])
         return(true);
   }
   return(false);
}

//+------------------------------------------------------------------+
