//+------------------------------------------------------------------+
//|                                                COT-Indicator.mq5 |
//|                                                           Volder |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Volder"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
#property script_show_inputs

#property indicator_label1 "Commercial Long"
#property indicator_label2 "Commercial Short"
#property indicator_label3 "Commercial All"
#property indicator_label4 "Open Interest"
#property indicator_label5 "Open%Interest"

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

#property indicator_color1 clrRed
#property indicator_color2 clrLime
#property indicator_color3 clrGreen
#property indicator_color4 clrBlack
#property indicator_color5 clrDarkSlateGray

enum Instruments {
   CURRENT = 0,                                          //Текущий инструмент
   EURO_FX,
   BRITISH_POUND_STERLING,
   AUSTRALIAN_DOLLAR,
   NEW_ZEALAND_DOLLAR,
   JAPANESE_YEN,
   CANADIAN_DOLLAR,
   SWISS_FRANC,
   RUSSIAN_RUBLE,
   SILVER,
   GOLD,
   WHEAT_SRW,
   BITCOIN,
   NASDAQ_100,
   E_MINI_RUSSELL_2000_INDEX,
   E_MINI_SP_500_STOCK_INDEX,
   COFFEE_C,
   CORN,
   COCOA,
   COTTON,
   SOYBEANS,
   SUGAR_NO_11,
   CRUDE_OIL_LIGHT_SWEET,
   COPPER_GRADE_1,
   PALLADIUM,
   PLATINUM
};


string instruments[] = {
   "CURRENT",
   "\"EURO FX - CHICAGO MERCANTILE EXCHANGE\"",
   "\"BRITISH POUND STERLING - CHICAGO MERCANTILE EXCHANGE\"",
   "\"AUSTRALIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE\"",
   "\"NEW ZEALAND DOLLAR - CHICAGO MERCANTILE EXCHANGE\"",
   "\"JAPANESE YEN - CHICAGO MERCANTILE EXCHANGE\"",
   "\"CANADIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE\"",
   "\"SWISS FRANC - CHICAGO MERCANTILE EXCHANGE\"",
   "\"RUSSIAN RUBLE - CHICAGO MERCANTILE EXCHANGE\"",
   "\"SILVER - COMMODITY EXCHANGE INC.\"",
   "\"GOLD - COMMODITY EXCHANGE INC.\"",
   "\"WHEAT-SRW - CHICAGO BOARD OF TRADE\"",
   "\"BITCOIN - CHICAGO MERCANTILE EXCHANGE\"",
   "\"NASDAQ-100 STOCK INDEX (MINI) - CHICAGO MERCANTILE EXCHANGE\"",
   "\"E-MINI RUSSELL 2000 INDEX - CHICAGO MERCANTILE EXCHANGE\"",
   "\"E-MINI S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE\"",
   "\"COFFEE C - ICE FUTURES U.S.\"",
   "\"CORN - CHICAGO BOARD OF TRADE\"",
   "\"COCOA - ICE FUTURES U.S.\"",
   "\"COTTON NO. 2 - ICE FUTURES U.S.\"",
   "\"SOYBEANS - CHICAGO BOARD OF TRADE\"",
   "\"SUGAR NO. 11 - ICE FUTURES U.S.\"",
   "\"CRUDE OIL, LIGHT SWEET - NEW YORK MERCANTILE EXCHANGE\"",
   "\"COPPER-GRADE #1 - COMMODITY EXCHANGE INC.\"",
   "\"PALLADIUM - NEW YORK MERCANTILE EXCHANGE\"",
   "\"PLATINUM - NEW YORK MERCANTILE EXCHANGE\""
};


input Instruments current_instrument = CURRENT;        //Отобразить на графике
input ENUM_DRAW_TYPE styling1 = DRAW_LINE;               //Commercial Long
input ENUM_DRAW_TYPE styling2 = DRAW_LINE;               //Commercial Short
input ENUM_DRAW_TYPE styling3 = DRAW_NONE;               //Commercial All
input ENUM_DRAW_TYPE styling4 = DRAW_NONE;               //Open Interest
input ENUM_DRAW_TYPE styling5 = DRAW_NONE;               //Open%Interest

input int period = 26;
int p = period*5;

//--- indicator buffers
double         ComLongBuf[];
double         ComShortBuf[];
double         ComAllBuf[];
double         OIBuf[];
double         OIPersBuf[];

string current_symbol;
string current_instr = instruments[current_instrument];

int file2017;
int file2018;
int file2019;
int file2020;
int file2021;
int file2022;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Запуск индикатора COT");
//--- indicator buffers mapping
   SetIndexBuffer(0, ComLongBuf, INDICATOR_DATA);
   SetIndexBuffer(1, ComShortBuf, INDICATOR_DATA);
   SetIndexBuffer(2, ComAllBuf, INDICATOR_DATA);
   SetIndexBuffer(3, OIBuf, INDICATOR_DATA);
   SetIndexBuffer(4, OIPersBuf, INDICATOR_DATA);
   
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, styling1);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, styling2);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, styling3);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, styling4);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, styling5);
   PlotIndexSetDouble (0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble (1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble (2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble (3, PLOT_EMPTY_VALUE, 0.0);
   
   
   if(current_instr == "CURRENT") {
      current_symbol = Symbol();
      if (current_symbol == "EURUSD") current_instr = "\"EURO FX - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "GBPUSD") current_instr = "\"BRITISH POUND STERLING - CHICAGO MERCANTILE EXCHANGE\", \"BRITISH POUND - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "AUDUSD") current_instr = "\"AUSTRALIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "NZDUSD") current_instr = "\"NEW ZEALAND DOLLAR - CHICAGO MERCANTILE EXCHANGE\", \"NZ DOLLAR - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "USDJPY") current_instr = "\"JAPANESE YEN - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "USDCAD") current_instr = "\"CANADIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "USDCHF") current_instr = "\"SWISS FRANC - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "USDRUB") current_instr = "\"RUSSIAN RUBLE - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "SILVER") current_instr = "\"SILVER - COMMODITY EXCHANGE INC.\"";
      else if (current_symbol == "GOLD") current_instr = "\"GOLD - COMMODITY EXCHANGE INC.\"";
      else if (StringFind(current_symbol, "Wheat", 0) >=0) current_instr = "\"WHEAT-SRW - CHICAGO BOARD OF TRADE\"";
      else if (current_symbol == "BTCUSD") current_instr = "\"BITCOIN - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "NQ") current_instr = "\"NASDAQ-100 STOCK INDEX (MINI) - CHICAGO MERCANTILE EXCHANGE\"";
      else if (current_symbol == "TF") current_instr = "\"E-MINI RUSSELL 2000 INDEX - CHICAGO MERCANTILE EXCHANGE\"";
      else if (StringFind(current_symbol, "US500", 0) >=0) current_instr = "\"E-MINI S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE\", \"E-MINI S&P 500 - CHICAGO MERCANTILE EXCHANGE\"";
      else if (StringFind(current_symbol, "Coffee", 0) >=0) current_instr = "\"COFFEE C - ICE FUTURES U.S.\"";
      else if (StringFind(current_symbol, "Corn", 0) >=0) current_instr = "\"CORN - CHICAGO BOARD OF TRADE\"";
      else if (StringFind(current_symbol, "Cocoa", 0) >=0) current_instr = "\"COCOA - ICE FUTURES U.S.\"";
      else if (StringFind(current_symbol, "Cotton", 0) >=0) current_instr = "\"COTTON NO. 2 - ICE FUTURES U.S.\"";
      else if (StringFind(current_symbol, "SBean", 0) >=0) current_instr = "\"SOYBEANS - CHICAGO BOARD OF TRADE\"";
      else if (StringFind(current_symbol, "Sugar", 0) >=0) current_instr = "\"SUGAR NO. 11 - ICE FUTURES U.S.\"";
      else if (current_symbol == "WTI") current_instr = "\"WTI-PHYSICAL - NEW YORK MERCANTILE EXCHANGE\", \"CRUDE OIL, LIGHT SWEET - NEW YORK MERCANTILE EXCHANGE\"";
      else if (StringFind(current_symbol, "GAS", 0) >=0) current_instr = "\"NATURAL GAS - NEW YORK MERCANTILE EXCHANGE\", \"NAT GAS NYME - NEW YORK MERCANTILE EXCHANGE\"";
      else if (current_symbol == "HG") current_instr = "\"COPPER-GRADE #1 - COMMODITY EXCHANGE INC.\"";
      else if (current_symbol == "PALLADIUM") current_instr = "\"PALLADIUM - NEW YORK MERCANTILE EXCHANGE\"";
      else if (current_symbol == "PLATINUM") current_instr = "\"PLATINUM - NEW YORK MERCANTILE EXCHANGE\"";
   
      else current_instr = "\"EURO FX - CHICAGO MERCANTILE EXCHANGE\"";
   }
   
   IndicatorSetString(INDICATOR_SHORTNAME, "COT: " + current_instr);
   
   
   file2017 = FileOpen("COT\\2017.txt", FILE_READ|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, '\t');
   if(file2017 == INVALID_HANDLE) Print("Файл 2017.txt не окрылся");
   else Print("Файл 2017.txt успешно окрыт");
   file2018 = FileOpen("COT\\2018.txt", FILE_READ|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, '\t');
   if(file2018 == INVALID_HANDLE) Print("Файл 2018.txt не окрылся");
   else Print("Файл 2018.txt успешно окрыт");
   file2019 = FileOpen("COT\\2019.txt", FILE_READ|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, '\t');
   if(file2019 == INVALID_HANDLE) Print("Файл 2019.txt не окрылся");
   else Print("Файл 2019.txt успешно окрыт");
   file2020 = FileOpen("COT\\2020.txt", FILE_READ|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, '\t');
   if(file2020 == INVALID_HANDLE) Print("Файл 2020.txt не окрылся");
   else Print("Файл 2020.txt успешно окрыт");
   file2021 = FileOpen("COT\\2021.txt", FILE_READ|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, '\t');
   if(file2021 == INVALID_HANDLE) Print("Файл 2021.txt не окрылся");
   else Print("Файл 2021.txt успешно окрыт");
   file2022 = FileOpen("COT\\annual.txt", FILE_READ|FILE_SHARE_READ|FILE_TXT|FILE_ANSI, '\t');
   if(file2022 == INVALID_HANDLE) Print("Файл annual.txt не окрылся");
   else Print("Файл annual.txt успешно окрыт");
   
   
   return(INIT_SUCCEEDED);
  }
  
  

void RemakeArray(string &array[])
{
   array[1] = array[0] + "," + array[1];
   for(int i = 0; i+1 < ArraySize(array); ++i) {
      array[i] = array[i+1];
   }
}

void file_handler(int file, int &i, const datetime &time[])
{
   string string_array[];
   string filestring;
   string instr_name;
   string that_time;
   string instr_time;
   
   
   FileSeek(file, 0, SEEK_SET);
   
   while (true) {
      filestring = FileReadString(file);
      StringSplit(filestring, ',', string_array);
      if(current_symbol == "WTI" && string_array[0] == "\"CRUDE OIL") {
         RemakeArray(string_array);
      }
      
      instr_name = string_array[0];
      //if(current_symbol == "WTI")
      //   Print(instr_name);
      if (StringFind(current_instr, instr_name,  0) >=0)
         break;
      if (FileIsEnding(file))
         return;
   }
     
   while (true) {
      instr_time = string_array[2];
      StringReplace(instr_time, "-", ".");
      while (true) {
         that_time = TimeToString(time[i], TIME_DATE);
         if(that_time == instr_time) {
            ComLongBuf[i] = StringToDouble(string_array[11]);
            ComShortBuf[i] = StringToDouble(string_array[12]);
            OIBuf[i] = StringToDouble(string_array[7]);
            ComAllBuf[i] = ComLongBuf[i] - ComShortBuf[i];
            break;
         }
         else {
            
            --i;
            if (i <= 0)
               return;
         }
      }
      filestring = FileReadString(file);
      StringSplit(filestring, ',', string_array);
      if(current_symbol == "WTI" && string_array[0] == "\"CRUDE OIL") {
         RemakeArray(string_array);
      }
      instr_name = string_array[0];
      if(StringFind(current_instr, instr_name,  0) <0) 
         break;
  }
   
}    


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
   int start = 0;

   if(prev_calculated == 0) {
      ArrayInitialize(ComLongBuf, 0);
      ArrayInitialize(ComShortBuf, 0);
      ArrayInitialize(ComAllBuf, 0);
      ArrayInitialize(OIBuf, 0);
      ArrayInitialize(OIPersBuf, 0);
      int i = rates_total - 1;
      
      
      while (true) {
         file_handler(file2022, i, time);
         if (i <=0) break;
         file_handler(file2021, i, time);
         if (i <=0) break;
         file_handler(file2020, i, time);
         if (i <=0) break;
         file_handler(file2019, i, time);
         if (i <=0) break;
         file_handler(file2018, i, time);
         if (i <=0) break;
         file_handler(file2017, i, time);
         if (i <=0) break;
      }
      
      int startpersoi = i+1;
         
      for(int i = 1; i < rates_total; ++i) {
         if(ComLongBuf[i] == 0)
            ComLongBuf[i] = ComLongBuf[i-1];
         if(ComShortBuf[i] == 0)
            ComShortBuf[i] = ComShortBuf[i-1];
         if(ComAllBuf[i] == 0)
            ComAllBuf[i] = ComAllBuf[i-1];
         if(OIBuf[i] == 0)
            OIBuf[i] = OIBuf[i-1];
      }
      for (int j = startpersoi + p - 1; j < rates_total; ++j) {
         OIPersBuf[j] = 100*(
            (OIBuf[j] - OIBuf[ArrayMinimum(OIBuf, j - p + 1, p)])/
            (OIBuf[ArrayMaximum(OIBuf, j - p + 1, p)] - OIBuf[ArrayMinimum(OIBuf, j - p + 1, p)])
         );
      }
   }
   else {
      ComLongBuf[rates_total-1] = ComLongBuf[rates_total-2];
      ComShortBuf[rates_total-1] = ComShortBuf[rates_total-2];
      ComAllBuf[rates_total-1] = ComAllBuf[rates_total-2];
      OIBuf[rates_total-1] = OIBuf[rates_total-2];
   }


   return(rates_total);
}
//+------------------------------------------------------------------+
