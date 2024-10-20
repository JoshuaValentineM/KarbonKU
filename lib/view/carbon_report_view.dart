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
                      '${carbonReportPercentage.toInt()}%',
                      style: TextStyle(
                        color: (carbonReportPercentage > 100)
                            ? const Color(0xFFD66666)
                            : const Color(
                                0xFF66D6A6), // Mengubah warna teks berdasarkan nilai
                        fontSize: 75,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox( width: (carbonReportPercentage > 100) ? 16 : 38),
                    Image.asset(
                      'assets/img/ReportDivider.png',
                      height: 100,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${totalCarbonEmitted.toString()}kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Image.asset(
                              'assets/img/leaf.png',
                              height: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${totalDistanceTraveled.toString()}km',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/img/pin_range.png',
                              height: 16,
                            ),
                          ],
                        ),
                      ],
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
