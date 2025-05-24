class Ticker {
  final String symbol;
  final double lastPrice;
  final double price24hPcnt;
  final double highPrice24h;
  final double lowPrice24h;
  final double volume24h;

  Ticker({
    required this.symbol,
    required this.lastPrice,
    required this.price24hPcnt,
    required this.highPrice24h,
    required this.lowPrice24h,  
    required this.volume24h,
  });

  factory Ticker.fromJson(Map<String, dynamic> json) {
    return Ticker(
      symbol: json['symbol'],
      lastPrice: double.parse(json['lastPrice']),
      price24hPcnt: double.parse(json['price24hPcnt']) * 100,
      highPrice24h: double.parse(json['highPrice24h']),
      lowPrice24h: double.parse(json['lowPrice24h']),
      volume24h: double.parse(json['volume24h']),
    );
  }
}
