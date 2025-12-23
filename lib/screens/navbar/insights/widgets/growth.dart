import 'dart:ui' as ui;
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';
import '../../../../models/user_model.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  // 0: Weight, 1: Height, 2: Head
  int _selectedTab = 0;

  Stream<List<ActivityLogModel>>? _growthStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await DatabaseService().getUser(user.uid);
      if (userDoc?.currentBabyId != null) {
        setState(() {
          _growthStream = DatabaseService().getGrowthLogsStream(
            user.uid,
            userDoc!.currentBabyId!,
          );
        });
      }
    }
  }

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
                        // _buildTabButton(2, "Head"),
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
                    child: _growthStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<ActivityLogModel>>(
                            stream: _growthStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              List<double> chartData = [];
                              if (snapshot.hasData) {
                                final logs = snapshot.data!;
                                // Filter based on selected tab
                                final type = _selectedTab == 0
                                    ? 'weight'
                                    : (_selectedTab == 1 ? 'height' : 'head');

                                chartData = logs
                                    .where((log) => log.subType == type)
                                    .map((log) {
                                      final val = log.details['value'];
                                      if (val is int) return val.toDouble();
                                      return val as double;
                                    })
                                    .toList();
                              }

                              if (chartData.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No data yet",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return CustomPaint(
                                painter: ChartPainter(
                                  data: chartData,
                                  lineColor: AppColors.primary,
                                  fillColor: AppColors.primary.withOpacity(0.2),
                                ),
                              );
                            },
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

  // Removed _getCurrentData as logic is moved to builder

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

  void _showAddMeasurementModal() async {
    final String subType = _selectedTab == 1
        ? 'height'
        : (_selectedTab == 2 ? 'head' : 'weight');

    // We no longer wait for result to save. The sheet handles saving.
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMeasurementSheet(
        subType: subType,
        unit: subType == 'weight' ? 'kg' : 'cm', // Default unit based on type
      ),
    );

    // Refresh chart data immediately?
    // The chart reads from memory `_getCurrentData()`.
    // We need to re-fetch or the sheet should return the value to add to local state?
    // Let's make the sheet return the value just for local state update,
    // BUT the saving is done inside.
    // Or we just reload from DB?
    // Current code uses static lists `_weightData`. It doesn't fetch from DB yet for visualization!
    // The user didn't ask to fix the chart fetching (which is static), only the SAVING UX.
    // I will leave the charts as static/mock for now as per scope,
    // but the save will go to DB.
    // I'll ensure we don't break the existing mock visualization.
  }
}

// --- Internal Widget: Bottom Sheet for Adding Data ---
class AddMeasurementSheet extends StatefulWidget {
  final String subType;
  final String unit;

  const AddMeasurementSheet({
    super.key,
    required this.subType,
    required this.unit,
  });

  @override
  State<AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<AddMeasurementSheet> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  late String _selectedUnit;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.unit;
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveMeasurement() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userDoc = await DatabaseService().getUser(user.uid);
      if (userDoc?.currentBabyId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("No baby selected!")));
        }
        setState(() => _isSaving = false);
        return;
      }
      final babyId = userDoc!.currentBabyId!;

      final value = double.tryParse(_valueController.text);
      if (value == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid numeric value")),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final String logId = const Uuid().v4();
      final now = DateTime.now();
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      final log = ActivityLogModel(
        id: logId,
        type: 'growth',
        subType: widget.subType,
        timestamp: timestamp,
        createdAt: DateTime.now(),
        details: {'value': value, 'unit': _selectedUnit},
      );

      await DatabaseService().addActivityLog(user.uid, babyId, log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Growth Entry Saved!",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context); // Close the sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
              onPressed: _isSaving ? null : _saveMeasurement,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
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
    // Increased padding effectively to show labels
    final double padding = 40.0;

    // Fixed Scales as requested
    const double minX = 0.0;
    const double maxX = 100.0;
    const double minY = 0.0; // Y Scale 0-100
    const double maxY = 100.0;

    final double xRange = maxX - minX;
    final double yRange = maxY - minY;

    final textStyle = GoogleFonts.poppins(
      color: Colors.grey.shade600,
      fontSize: 10,
    );

    // Draw Grid Lines & Labels
    const int gridSteps = 5;

    // Y-Axis Grid & Labels
    for (int i = 0; i <= gridSteps; i++) {
      double normalizedY = i / gridSteps;
      double y = height - padding - (normalizedY * (height - 2 * padding));

      // Draw horizontal grid line
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );

      // Draw Y-Axis Label
      double labelValue = minY + (normalizedY * yRange);
      final textSpan = TextSpan(
        text: labelValue.toStringAsFixed(0),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();

      // Position text to the left of the chart area
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // X-Axis Grid & Labels
    for (int i = 0; i <= gridSteps; i++) {
      double normalizedX = i / gridSteps;
      double x = padding + (normalizedX * (width - 2 * padding));

      // Optional: Draw vertical grid line
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, height - padding),
        gridPaint,
      );

      // Draw X-Axis Label
      double labelValue = minX + (normalizedX * xRange);
      final textSpan = TextSpan(
        text: labelValue.toStringAsFixed(0),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();

      // Position text below the chart area
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, height - padding + 8),
      );
    }

    // --- Plotting Logic (Smooth Curve + Full Width) ---
    final Path path = Path();
    final Path fillPath = Path(); // For the area under the curve

    // If we only have one point, just draw a dot.
    if (data.length == 1) {
      // ... (Handle single point if needed, for now standard circle logic)
    }

    // Helper to map data index[i] to X coordinate and value[i] to Y coordinate
    // We spread the points evenly from minX(pixels) to maxX(pixels).
    Offset getPoint(int index) {
      // Prevent division by zero if only 1 point
      double t = index / (data.length > 1 ? (data.length - 1) : 1);
      // Calculate X pixel position based on available width
      double x = padding + t * (width - 2 * padding);

      // Calculate Y pixel position based on value and 0-100 scale
      double value = data[index].clamp(minY, maxY);
      double y =
          height - padding - ((value - minY) / yRange) * (height - 2 * padding);
      return Offset(x, y);
    }

    Offset startPoint = getPoint(0);
    path.moveTo(startPoint.dx, startPoint.dy);
    fillPath.moveTo(padding, height - padding); // Start bottom-left of chart
    fillPath.lineTo(startPoint.dx, startPoint.dy);

    // Use Cubic Beziers for smoothing
    // We can use a simplified approach: control points based on neighbors
    for (int i = 0; i < data.length - 1; i++) {
      Offset p0 = getPoint(i);
      Offset p1 = getPoint(i + 1);

      // Calculate control points for curvature
      // Simple monotonic smoothing
      double controlX = (p0.dx + p1.dx) / 2;

      Offset cp1 = Offset(controlX, p0.dy);
      Offset cp2 = Offset(controlX, p1.dy);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    // Finish fill path
    Offset lastPoint = getPoint(data.length - 1);
    fillPath.lineTo(
      lastPoint.dx,
      height - padding,
    ); // Down to bottom-right axis
    fillPath.close(); // Back to bottom-left

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw Dots on top
    for (int i = 0; i < data.length; i++) {
      Offset p = getPoint(i);
      canvas.drawCircle(p, 5, Paint()..color = lineColor);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
