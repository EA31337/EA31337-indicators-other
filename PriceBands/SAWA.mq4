//+------------------------------------------------------------------+
//|                                                         SAWA.mq4|
//|                                                         indicator|
//|                                              http://fx.essawa.com|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016 | SAWA.com"
#property link      " http://fx.essawa.com"
#property version   "1.002"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
#property indicator_width1  2
#property indicator_width2  2
//---- input parameters

extern int       CCI_per=14;
extern int       RSI_per=14;
extern int       Ma_Period=2;
extern int       Koef=8;
extern bool arrows=true;

double a=0,a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0,a8=0;
double b=0,b1=0,b2=0,b3=0,b4=0,b5=0,b6=0,b7=0,b8=0;
double tt1max=0,tt2min=0;
int koef = Koef;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
string sPrefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexBuffer(0,ExtMapBuffer1, INDICATOR_DATA);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexBuffer(1,ExtMapBuffer2, INDICATOR_DATA);

   SetIndexBuffer(2,ExtMapBuffer3, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtMapBuffer4, INDICATOR_CALCULATIONS);

   SetIndexLabel(0,"CCI-RSI");
   SetIndexLabel(1,"RSI-CCI");
   if(koef>8 || koef<0)koef=8;
   sPrefix="SAWA("+(string) CCI_per+", "+(string) RSI_per+": "+(string) koef+" )";
   IndicatorShortName(sPrefix);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   DelOb();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, limit=Bars-IndicatorCounted();

   for(i=limit-3;i>=0;i--)
     {

      a=iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i);
      if(i-1>=0) a1=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-1)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+1));
      if(i-2>=0) a2=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-2)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+2));
      if(i-3>=0) a3=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-3)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+3));
      if(i-4>=0) a4=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-4)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+4));
      if(i-5>=0) a5=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-5)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+5));
      if(i-6>=0) a6=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-6)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+6));
      if(i-7>=0) a7=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-7)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+7));
      if(i-8>=0) a8=(iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i-8)-iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i+8));


      b=iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i);
      if(i-1>=0) b1=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-1)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+1));
      if(i-2>=0) b2=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-2)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+2));
      if(i-3>=0) b3=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-3)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+3));
      if(i-4>=0) b4=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-4)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+4));
      if(i-5>=0) b5=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-5)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+5));
      if(i-6>=0) b6=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-6)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+6));
      if(i-7>=0) b7=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-7)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+7));
      if(i-8>=0) b8=(iRSI(NULL,0,RSI_per,PRICE_TYPICAL,i-8)-iCCI(NULL,0,CCI_per,PRICE_TYPICAL,i+8));

      switch(koef)
        {
         case 0     : tt1max=a; tt2min=b; break;
         case 1     : tt1max=a+a1; tt2min=b+b1; break;
         case 2     : tt1max=a+a1+a2; tt2min=b+b1+b2; break;
         case 3     : tt1max=a+a1+a2+a3; tt2min=b+b1+b2+b3; break;
         case 4     : tt1max=a+a1+a2+a3+a4; tt2min=b+b1+b2+b3+b4; break;
         case 5     : tt1max=a+a1+a2+a3+a4+a5; tt2min=b+b1+b2+b3+b4+b5; break;
         case 6     : tt1max=a+a1+a2+a3+a4+a5+a6; tt2min=b+b1+b2+b3+b4+b5+b6; break;
         case 7     : tt1max=a+a1+a2+a3+a4+a5+a6+a7; tt2min=b+b1+b2+b3+b4+b5+b6+b7; break;
         case 8     : tt1max=a+a1+a2+a3+a4+a5+a6+a7+a8; tt2min=b+b1+b2+b3+b4+b5+b6+b7+b8; break;
         default    : tt1max=a+a1+a2+a3+a4+a5+a6+a7+a8; tt2min=b+b1+b2+b3+b4+b5+b6+b7+b8;
        }

      ExtMapBuffer3[i]=tt1max;
      ExtMapBuffer4[i]=tt2min;

     }

   for(i=0; i<limit && !IsStopped(); i++)
     {

      ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer3,Bars,Ma_Period,0,MODE_SMA,i);
      ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer4,Bars,Ma_Period,0,MODE_SMA,i);
     }
   for(i=0; i<limit-1 && !IsStopped(); i++)
     {
      if(arrows)
        {
         if(ExtMapBuffer1[i]>=ExtMapBuffer2[i] && ExtMapBuffer1[i+1]<ExtMapBuffer2[i+1])
           {
            DrawAr("up",i);
           }
         if(ExtMapBuffer1[i]<=ExtMapBuffer2[i] && ExtMapBuffer1[i+1]>ExtMapBuffer2[i+1])
           {
            DrawAr("dn",i);
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelOb()
  {
   int n=ObjectsTotal();
   for(int i=n-1; i>=0; i--)
     {
      string sName=ObjectName(i);
      if(StringFind(sName,sPrefix)==0)
        {
         ObjectDelete(sName);
        }
     }
  }
//----------------------------------------------------------------------
void DrawAr(string ssName,int i)
  {
   string sName=sPrefix+" "+ssName+" "+TimeToStr(Time[i],TIME_DATE|TIME_MINUTES);
   ObjectDelete(sName);
   ObjectCreate(sName,OBJ_ARROW,0,Time[i],0);
   double gap=3.0*iATR(NULL,0,20,i)/4.0;
   if(ssName=="up")
     {
      ObjectSet(sName,OBJPROP_ARROWCODE,225);
      ObjectSet(sName,OBJPROP_PRICE1,Low[i]-gap);
      ObjectSet(sName,OBJPROP_COLOR,DeepSkyBlue);
     }
   if(ssName=="dn")
     {
      ObjectSet(sName,OBJPROP_ARROWCODE,226);
      ObjectSet(sName,OBJPROP_PRICE1,High[i]+gap*3.0);
      ObjectSet(sName,OBJPROP_COLOR,Red);
     }
   ObjectSet(sName,OBJPROP_WIDTH,2);
  }
//+------------------------------------------------------------------+
