import 'package:flutter/material.dart';

class CarbonReportView extends StatelessWidget {
  final double carbonReportPercentage;
  final double totalCarbonEmitted;
  final double totalDistanceTraveled;
  final String reportType; // Daily or Weekly
  final int currentPage; // Tambahkan parameter untuk halaman saat ini

  const CarbonReportView({
    Key? key,
    required this.carbonReportPercentage,
    required this.totalCarbonEmitted,
    required this.totalDistanceTraveled,
    required this.reportType,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 215,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A373B), Color(0xFF3B645E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Carbon Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      width: 85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        reportType,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      carbonReportPercentage > 100
                          ? '>100%'
                          : '${carbonReportPercentage.toInt()}%',
                      style: TextStyle(
                        color: (carbonReportPercentage >= 100)
                            ? const Color(
                                0xFFD66666) // Warna merah jika lebih dari 100%
                            : (carbonReportPercentage > 75)
                                ? const Color.fromARGB(255, 246, 162,
                                    44) // Warna FFB323 jika antara 75% dan 100%
                                : const Color(
                                    0xFF66D6A6), // Warna hijau jika di bawah 75%

                        fontSize: carbonReportPercentage > 100 ? 64 : 75,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: (carbonReportPercentage >= 100)
                          ? 16
                          : (carbonReportPercentage < 100 &&
                                  carbonReportPercentage >= 10)
                              ? 48 // Lebar untuk 2 digit
                              : 72, // Lebar untuk 1 digit (atau lebih besar jika perlu)
                    ),
                    Image.asset(
                      'assets/img/ReportDivider.png',
                      height: 100,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${(totalCarbonEmitted / 1000).toStringAsFixed(totalCarbonEmitted / 1000 >= 10 ? 1 : 2)}kg',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/img/leaf.png',
                                height: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${(totalDistanceTraveled / 1000).toStringAsFixed(totalDistanceTraveled / 1000 >= 10 ? 1 : 2)}km',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/img/pin_range.png',
                                height: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      '*berdasarkan Maximum Carbon Standard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Row(
                      children: List.generate(4, (index) {
                        Color circleColor = (index == currentPage)
                            ? Colors.white
                            : Colors.grey; // Mengubah warna berdasarkan halaman
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: circleColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
