#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Magenta     // Sell
#property indicator_color3 DodgerBlue  // Buy
#property indicator_color4 LimeGreen   // Buy
#property indicator_color5 Plum        // Buy

extern ENUM_TIMEFRAMES TickChartPeriod = PERIOD_CURRENT;  // Period of the original tick chart data in minutes

bool TrendLine = true;
int TrendLineStyle = STYLE_DOT;
int TrendLineWidth = 1;
color UpperTrendLineColour = clrLimeGreen;
color LowerTrendLineColour = clrRed;

double ChartOpen[];   // Array to store opening prices of current bars
double ChartHigh[];   // Array to store highest prices of current bars
double ChartLow[];    // Array to store lowest prices of current bars
double ChartClose[];  // Array to store closing prices of current bars
int BarNumber;        // Number of bars in offline chart

int ChartPrecision = 5;  // Number of decimal places in displayed tick chart prices

double M2O;          // Multiplier used to convert ticks to offline chart bars
double LastPrice[];  // Array to store last prices received from tick chart data

int init() {
  IndicatorShortName("Tick Chart");

  string plotLabel = "tick_chart";
  PlotIndexSetString(0, PLOT_LABEL, plotLabel);

  // Set up buffers for the arrays
  SetIndexBuffer(0, ChartOpen);
  SetIndexBuffer(1, ChartHigh);
  SetIndexBuffer(2, ChartLow);
  SetIndexBuffer(3, ChartClose);
  SetIndexBuffer(4, LastPrice);

  return (0);
}

int start() {
  M2O = PeriodSeconds(Period()) / PeriodSeconds(Period());  // Calculate multiplier
  BarNumber = iBars(NULL, 0) - 1;                           // Get number of bars in current offline chart

  // Main loop for updating offline chart data
  for (int i = BarNumber; i > 0; i--) {
    ChartOpen[i] = iOpen(NULL, 0, i);    // Get open price of current bar
    ChartHigh[i] = iHigh(NULL, 0, i);    // Get high price of current bar
    ChartLow[i] = iLow(NULL, 0, i);      // Get low price of current bar
    ChartClose[i] = iClose(NULL, 0, i);  // Get close price of current bar

    // Determine current tick chart price
    if (LastPrice[i] == 0)
      LastPrice[i] = iClose(NULL, (int)TickChartPeriod, 0);
    else
      LastPrice[i] = iClose(NULL, (int)TickChartPeriod, 1);

    // Update offline chart data
    if (LastPrice[i] > ChartHigh[i]) ChartHigh[i] = LastPrice[i];
    if (LastPrice[i] < ChartLow[i]) ChartLow[i] = LastPrice[i];
    ChartClose[i] = LastPrice[i];

    RefreshRates();                                                // Refresh market data
    LastPrice[i] = NormalizeDouble(LastPrice[i], ChartPrecision);  // Round tick chart price

    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    ChartOpen[i - 1] = LastPrice[i];
    // PlotIndexSetDouble(0, i - 1, ChartOpen[i - 1]);
  }

  if (TrendLine) {
    // Delete previous trendlines
    // Delete previous trendlines
    for (int j = ObjectsTotal() - 1; j >= 0; j--) {
      string objName = ObjectName(j);
      if (StringSubstr(objName, 0, 4) == "HHL_") ObjectDelete(objName);
    }

    // Draw trendlines
    int numBars = iBars(NULL, 0);
    int stepSize = (int)MathPow(10, ChartPrecision);  // Step size for trendline drawing
    int startBar = (int)(numBars - MathCeil((double)numBars / stepSize * stepSize));
    int endBar = numBars - 1;

    if (TrendLine) {
      for (int k = startBar; k < endBar; k += stepSize) {
        TrendLineLowTD(k, endBar, k, TrendLineStyle, LowerTrendLineColour);
      }
    }
  }

  return (0);
}

int TrendLineLowTD(int L1, int i, int Step, double St, int Col) {
  double price = ChartLow[i] + (ChartLow[L1] - ChartLow[i]) / (i - L1) * i;
  ObjectSet("HHL_" + (string)Step, OBJPROP_TIME1, Time[i]);
  ObjectSet("LL_" + (string)Step, OBJPROP_TIME2, Time[L1]);
  ObjectCreate("HHL_" + (string)Step, OBJ_HLINE, 0, 0, price);
  ObjectSet("HHL_" + (string)Step, OBJPROP_STYLE, St);

  ObjectSet("HHL_" + (string)Step, OBJPROP_BACK, true);  // Line added
  ObjectSet("HHL_" + (string)Step, OBJPROP_COLOR, LowerTrendLineColour);
  if (Step == 1)
    ObjectSet("HHL_" + (string)Step, OBJPROP_WIDTH, TrendLineWidth);
  else
    ObjectSet("HHL_" + (string)Step, OBJPROP_WIDTH, 1);
  return (0);
}
