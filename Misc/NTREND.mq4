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
#property indicator_buffers 6
#property indicator_color1 CLR_NONE
#property indicator_color2 CLR_NONE
#property indicator_color3 CLR_NONE
#property indicator_color4 CLR_NONE
#property indicator_color5 DeepSkyBlue
#property indicator_width5 10
#property indicator_color6 Violet
#property indicator_width6 10

extern int Z   = 4;
extern int Z1  = 5;
extern int S   = 0;
extern int S1  = 0;
extern bool SendAlert = true;
extern bool SendEmail = false;
double gd_92;
double gd_100;
double gd_108;
double gd_116 = 0.0;
double gd_124;
double gd_132 = 0.0;
double gd_140;
double gd_148;
int gi_156 = 0;
double gd_unused_168 = 0.0;
int gi_unused_176 = 0;
double g_ibuf_180[];
double g_ibuf_184[];
double g_ibuf_188[];
double g_ibuf_192[];
double g_ibuf_196[];
double g_ibuf_200[];
double g_ibuf_204[];
double g_ibuf_208[];
static datetime dtBarTime;

int init() {
   IndicatorBuffers(8);
   SetIndexBuffer(6, g_ibuf_188);
   SetIndexBuffer(7, g_ibuf_192);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, g_ibuf_180);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, g_ibuf_184);
   SetIndexDrawBegin(0, Z1 + 1);
   SetIndexDrawBegin(1, Z1 + 1);
   SetIndexDrawBegin(2, Z1 + 1);
   SetIndexDrawBegin(3, Z1 + 1);
   SetIndexDrawBegin(4, Z1 + 1);
   SetIndexDrawBegin(5, Z1 + 1);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, g_ibuf_196);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, g_ibuf_200);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 177);
   SetIndexBuffer(4, g_ibuf_204);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 177);
   SetIndexBuffer(5, g_ibuf_208);
   IndicatorShortName("NTrend");
   SetIndexLabel(0, "NTLine1");
   SetIndexLabel(1, "NTLine2");
   SetIndexLabel(2, "NTBar1");
   SetIndexLabel(3, "NTBar2");
   SetIndexLabel(4, "NTSig1");
   SetIndexLabel(5, "NTSig2");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_8;
   int li_unused_0 = MarketInfo(Symbol(), MODE_DIGITS);
   if (Bars <= Z1) return (0);
   int l_ind_counted_4 = IndicatorCounted();
   if (l_ind_counted_4 == 0) li_8 = Bars - 1;
   if (l_ind_counted_4 > 0) li_8 = Bars - l_ind_counted_4 - 1;
   for (int li_12 = li_8; li_12 >= 0; li_12--) {
      gd_92 = High[iHighest(NULL, 0, MODE_HIGH, Z, li_12)] + S * Point;
      gd_100 = Low[iLowest(NULL, 0, MODE_LOW, Z, li_12)] - S * Point;
      gd_108 = High[iHighest(NULL, 0, MODE_HIGH, Z1, li_12)] + S1 * Point;
      gd_116 = Low[iLowest(NULL, 0, MODE_LOW, Z1, li_12)] - S1 * Point;
      if (Close[li_12] > g_ibuf_180[li_12 + 1]) gd_124 = gd_100;
      else gd_124 = gd_92;
      if (Close[li_12] > g_ibuf_184[li_12 + 1]) gd_132 = gd_116;
      else gd_132 = gd_108;
      g_ibuf_180[li_12] = gd_124;
      g_ibuf_184[li_12] = gd_132;
      gd_140 = 0.0;
      gd_148 = 0.0;
      if (Close[li_12] < gd_124 && Close[li_12] < gd_132) {
         gd_140 = High[li_12];
         gd_148 = Low[li_12];
      }
      if (Close[li_12] > gd_124 && Close[li_12] > gd_132) {
         gd_140 = Low[li_12];
         gd_148 = High[li_12];
      }
      g_ibuf_196[li_12] = gd_140;
      g_ibuf_200[li_12] = gd_148;
      if (Close[li_12] > gd_132 && Close[li_12] > gd_124 && gi_156 != 1) {
         g_ibuf_204[li_12] = gd_132;
         g_ibuf_208[li_12] = EMPTY_VALUE;
         if (li_12 == 0) {
            if (dtBarTime != Time[0]) {
               dtBarTime = Time[0];
               if (SendAlert) Alert("NTrend alert! ",StringConcatenate(Symbol()," - Trend UP"));
               if (SendEmail) SendMail("NTrend alert! ",StringConcatenate("Alert for ",Symbol()));
               }
            }
         gi_156 = 1;
      }
      if (Close[li_12] < gd_132 && Close[li_12] < gd_124 && gi_156 != 2) {
         g_ibuf_208[li_12] = gd_132;
         g_ibuf_204[li_12] = EMPTY_VALUE;
         if (li_12 == 0) {
            if (dtBarTime != Time[0]) {
               dtBarTime = Time[0];
               if (SendAlert) Alert("NTrend alert! ",StringConcatenate(Symbol()," - Trend DOWN"));
               if (SendEmail) SendMail("NTrend alert! ",StringConcatenate("Alert for ",Symbol()));
               }
            }
         gi_156 = 2;
      }
   }

   return (0);
}

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
