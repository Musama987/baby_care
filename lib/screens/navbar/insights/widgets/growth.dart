import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  // 0: Weight, 1: Height, 2: Head
  int _selectedTab = 0;

  // Mock Data for the chart visualization
  final List<double> _weightData = [7.5, 9.2, 11.0, 12.5, 14.2, 16.0];
  final List<double> _heightData = [50, 54, 58, 61, 64, 66];
  final List<double> _headData = [35, 37, 39, 41, 42, 43];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF1E2623),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        // Title removed as requested, using body title instead
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Growth Charts",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E2623),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- Tabs (Weight | Height | Head) ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(0, "Weight"),
                        _buildTabButton(1, "Height"),
                        _buildTabButton(2, "Head"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Chart Section ---
                  Text(
                    _getChartTitle(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E2623),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Chart Visualization
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: ChartPainter(
                        data: _getCurrentData(),
                        lineColor: AppColors.primary,
                        fillColor: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Add Measurement Button ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _showAddMeasurementModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Add Measurement",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedTab) {
      case 1:
        return "Height (cm)";
      case 2:
        return "Head Circumference (cm)";
      default:
        return "Weight (lbs)";
    }
  }

  List<double> _getCurrentData() {
    switch (_selectedTab) {
      case 1:
        return _heightData;
      case 2:
        return _headData;
      default:
        return _weightData;
    }
  }

  Widget _buildTabButton(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMeasurementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMeasurementSheet(),
    );
  }
}

// --- Internal Widget: Bottom Sheet for Adding Data ---
class AddMeasurementSheet extends StatefulWidget {
  const AddMeasurementSheet({super.key});

  @override
  State<AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<AddMeasurementSheet> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _selectedUnit = 'kg'; // default unit

  @override
  void initState() {
    super.initState();
    // Set today as default
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "New Entry",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E2623),
            ),
          ),
          const SizedBox(height: 24),

          // --- Date Picker ---
          Text("Date", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
              filled: true,
              fillColor: const Color(0xFFF5F5F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Value & Unit ---
          Text(
            "Value",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "0.0",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textDark,
                        ),
                        style: GoogleFonts.poppins(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        items: ['kg', 'lb', 'cm', 'in'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUnit = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- Save Button ---
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Save Entry",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Chart Painter (No External Dependencies) ---
class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  ChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final double width = size.width;
    final double height = size.height;
    final double padding = 20.0;

    // Draw Grid Lines
    for (int i = 0; i <= 5; i++) {
      double y = height - padding - (i * (height - 2 * padding) / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final double xStep = (width - 2 * padding) / (data.length - 1);
    final double maxY =
        data.reduce((curr, next) => curr > next ? curr : next) * 1.2;
    final double minY =
        data.reduce((curr, next) => curr < next ? curr : next) * 0.8;

    final Path path = Path();
    final Path fillPath = Path();

    fillPath.moveTo(padding, height - padding);

    for (int i = 0; i < data.length; i++) {
      double x = padding + i * xStep;
      double y =
          height -
          padding -
          ((data[i] - minY) / (maxY - minY)) * (height - 2 * padding);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Draw smooth bezier curve
        double prevX = padding + (i - 1) * xStep;
        double prevY =
            height -
            padding -
            ((data[i - 1] - minY) / (maxY - minY)) * (height - 2 * padding);
        double cp1x = prevX + xStep / 2;
        double cp1y = prevY;
        double cp2x = x - xStep / 2;
        double cp2y = y;

        path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
      }

      // Draw Dot
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = lineColor);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }

    // Finish fill path
    // Reconstruct path for fill to ensure it closes at bottom
    fillPath.moveTo(padding, height - padding);
    for (int i = 0; i < data.length; i++) {
      double x = padding + i * xStep;
      double y =
          height -
          padding -
          ((data[i] - minY) / (maxY - minY)) * (height - 2 * padding);
      if (i == 0) {
        fillPath.lineTo(x, y);
      } else {
        double prevX = padding + (i - 1) * xStep;
        double prevY =
            height -
            padding -
            ((data[i - 1] - minY) / (maxY - minY)) * (height - 2 * padding);
        fillPath.cubicTo(prevX + xStep / 2, prevY, x - xStep / 2, y, x, y);
      }
    }
    fillPath.lineTo(width - padding, height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
