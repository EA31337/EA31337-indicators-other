//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73852

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1 DeepSkyBlue  // up[]
#property indicator_width1 2
#property indicator_color2 Tomato       // down[]
#property indicator_width2 2
#property indicator_color3 DeepSkyBlue  // atrlo[]
#property indicator_width3 1
#property indicator_color4 Tomato       // atrhi[]
#property indicator_width4 1
#property indicator_color5 DeepSkyBlue  // arrup[]
#property indicator_width5 1
#property indicator_color6 Tomato      // arrdwn[]
#property indicator_width6 1
#property indicator_color8 Lime
#property indicator_width8 2
#property indicator_color9 Red
#property indicator_width9 2


extern int    Amplitude        = 2;
extern int Z   = 4;
extern int Z1  = 5;
extern int S   = 0;
extern int S1  = 0;
extern bool   ShowBars         = false;
extern bool   ShowArrows       = false;
extern bool   ShowNArrows    = true;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern bool   pushNotifications = false;

bool nexttrend;
double minhighprice, maxlowprice;
double up[], down[], atrlo[], atrhi[], trend[];
double arrup[], arrdwn[];
double Narrup[], Narrdwn[];
double g_ibuf_180[];
double g_ibuf_184[];
double g_ibuf_188[];
double g_ibuf_192[];
double g_ibuf_196[];
double g_ibuf_200[];
double gd_124;
double gd_132;
double gd_140;
double gd_148;
int gi_156 = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(15); // +1 buffer - trend[]
   SetIndexBuffer(0, up);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1, down);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(2, atrlo);
   SetIndexBuffer(3, atrhi);
   SetIndexBuffer(6, trend);
   SetIndexBuffer(4, arrup);
   SetIndexBuffer(5, arrdwn);
   SetIndexBuffer(7, Narrup);
   SetIndexBuffer(8, Narrdwn);
//
   SetIndexBuffer(9, g_ibuf_180);
   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(10, g_ibuf_184);
   SetIndexStyle(10, DRAW_NONE);
   SetIndexBuffer(11, g_ibuf_188);
   SetIndexStyle(11, DRAW_NONE);
   SetIndexBuffer(12, g_ibuf_192);
   SetIndexStyle(12, DRAW_NONE);
   SetIndexBuffer(13, g_ibuf_196);
   SetIndexStyle(13, DRAW_NONE);
   SetIndexBuffer(14, g_ibuf_200);
   SetIndexStyle(14, DRAW_NONE);
//
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(6, 0.0);
   if(ShowBars)
     {
      SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID);
     }
   else
     {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
     }
   if(ShowArrows)
     {
      SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID);
      SetIndexArrow(4, 233);
      SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID);
      SetIndexArrow(5, 234);
     }
   else
     {
      SetIndexStyle(4, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
     }
   if(ShowNArrows)
     {
      SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID);
      SetIndexArrow(7, 221);
      SetIndexStyle(8, DRAW_ARROW, STYLE_SOLID);
      SetIndexArrow(8, 222);
     }
   else
     {
      SetIndexStyle(7, DRAW_NONE);
      SetIndexStyle(8, DRAW_NONE);
     }
   nexttrend = 0;
   minhighprice = High[Bars - 1];
   maxlowprice = Low[Bars - 1];
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFix { } ExtFix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double atr, lowprice_i, highprice_i, lowma, highma;
   int workbar = 0;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   for(int i = Bars - 1; i >= 0; i--)
     {
      lowprice_i = iLow(Symbol(), Period(), iLowest(Symbol(), Period(), MODE_LOW, Amplitude, i));
      highprice_i = iHigh(Symbol(), Period(), iHighest(Symbol(), Period(), MODE_HIGH, Amplitude, i));
      lowma = NormalizeDouble(iMA(NULL, 0, Amplitude, 0, MODE_SMA, PRICE_LOW, i), Digits());
      highma = NormalizeDouble(iMA(NULL, 0, Amplitude, 0, MODE_SMA, PRICE_HIGH, i), Digits());
      trend[i] = trend[i + 1];
      atr = iATR(Symbol(), 0, 100, i) / 2;
      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
      if(nexttrend == 1)
        {
         maxlowprice = MathMax(lowprice_i, maxlowprice);
         if(highma < maxlowprice && Close[i] < Low[i + 1])
           {
            trend[i] = 1.0;
            nexttrend = 0;
            minhighprice = highprice_i;
           }
        }
      if(nexttrend == 0)
        {
         minhighprice = MathMin(highprice_i, minhighprice);
         if(lowma > minhighprice && Close[i] > High[i + 1])
           {
            trend[i] = 0.0;
            nexttrend = 1;
            maxlowprice = lowprice_i;
           }
        }
      if(trend[i] == 0.0)
        {
         if(trend[i + 1] != 0.0)
           {
            up[i] = down[i + 1];
            up[i + 1] = up[i];
            arrup[i] = up[i] - 2 * atr;
           }
         else
           {
            up[i] = MathMax(maxlowprice, up[i + 1]);
           }
         atrhi[i] = up[i] - atr;
         atrlo[i] = up[i];
         down[i] = 0.0;
        }
      else
        {
         if(trend[i + 1] != 1.0)
           {
            down[i] = up[i + 1];
            down[i + 1] = down[i];
            arrdwn[i] = down[i] + 2 * atr;
           }
         else
           {
            down[i] = MathMin(minhighprice, down[i + 1]);
           }
         atrhi[i] = down[i] + atr;
         atrlo[i] = down[i];
         up[i] = 0.0;
        }
      if(ShowNArrows)
        {
         double gd_92 = High[iHighest(NULL, 0, MODE_HIGH, Z, i)] + S * Point;
         double gd_100 = Low[iLowest(NULL, 0, MODE_LOW, Z, i)] - S * Point;
         double gd_108 = High[iHighest(NULL, 0, MODE_HIGH, Z1, i)] + S1 * Point;
         double gd_116 = Low[iLowest(NULL, 0, MODE_LOW, Z1, i)] - S1 * Point;
         if(Close[i] > g_ibuf_180[i + 1])
            gd_124 = gd_100;
         else
            gd_124 = gd_92;
         if(Close[i] > g_ibuf_184[i + 1])
            gd_132 = gd_116;
         else
            gd_132 = gd_108;
         g_ibuf_180[i] = gd_124;
         g_ibuf_184[i] = gd_132;
         gd_140 = 0.0;
         gd_148 = 0.0;
         if(Close[i] < gd_124 && Close[i] < gd_132)
           {
            gd_140 = High[i];
            gd_148 = Low[i];
           }
         if(Close[i] > gd_124 && Close[i] > gd_132)
           {
            gd_140 = Low[i];
            gd_148 = High[i];
           }
         g_ibuf_196[i] = gd_140;
         g_ibuf_200[i] = gd_148;
         if(Close[i] > gd_132 && Close[i] > gd_124 && gi_156 != 1)
           {
            if(trend[i] == 0)
               Narrup[i] = Low[i] - atr;
            else
               Narrup[i] = 0.0;
            gi_156 = 1;
           }
         else
            Narrup[i] = 0.0;
         if(Close[i] < gd_132 && Close[i] < gd_124 && gi_156 != 2)
           {
            if(trend[i] == 1)
               Narrdwn[i] = High[i] + 2 * atr;
            else
               Narrdwn[i] = 0.0;
            gi_156 = 2;
           }
         else
            Narrdwn[i] = 0.0;
        }
     }
   manageAlerts();
   return (0);
  }
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts()
  {
   if(alertsOn)
     {
      if(alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      /* if(arrup[whichBar]  != EMPTY_VALUE)
          doAlert(whichBar, "up");
       if(arrdwn[whichBar] != EMPTY_VALUE)
          doAlert(whichBar, "down");*/
      if(Narrup[whichBar]  != 0.0 && Narrup[whichBar]  != EMPTY_VALUE)
         doAlert(whichBar, "up");
      if(Narrdwn[whichBar] != 0.0 && Narrdwn[whichBar] != EMPTY_VALUE)
         doAlert(whichBar, "down");
     }
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert = "nothing";
   static datetime previousTime;
   string message;
   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];
      //
      //
      //
      //
      //
      message =  StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " HalfTrend+PSR signal ", doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), " HalfTrend "), message);
      if(pushNotifications)
         SendNotification(message);
      if(alertsSound)
         PlaySound("alert2.wav");
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+
