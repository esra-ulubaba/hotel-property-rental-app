import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';
import 'package:otel_ve_emlak_kiralama/common/stripe/payment.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';

import '../../models/posting_objects.dart';
import '../../widgets/calendar_view_ui.dart';



class BookPostingPage extends StatefulWidget {
  static final String routeName = '/bookPostingPageRoute';

  final Posting? posting;
  const BookPostingPage({super.key, this.posting,});

  @override
  State<BookPostingPage> createState() => _BookPostingPageState();
}

class _BookPostingPageState extends State<BookPostingPage> {
  Posting? _posting;
  List<CalenderViewUi> _calendarWidgets = [];
  List<DateTime> _bookedDates = [];
  List<DateTime> _selectedDates = [];


  _buildCalendarWidgets() {
    for(int i = 0; i < 12; i++){
      _calendarWidgets.add(
          CalenderViewUi(
            monthIndex: i,
            bookedDates: _bookedDates,
            selectDate: _selectDate,
            getSelectedDates: _getSelectedDates,
          )
      );
    }
    setState(() {
    });
  }

  _loadBookedDates() {
    _posting!.getAllBookingsFromFirestore().whenComplete((){
      _bookedDates = _posting!.getAllBookedDates();
      _buildCalendarWidgets();
    });
  }

  _selectDate(DateTime date) {
    if(_selectedDates.contains(date)) {
      _selectedDates.remove(date);
    } else {
      _selectedDates.add(date);
    }

    _selectedDates.sort();

    setState(() {

    });
  }

  _getSelectedDates() {
    return _selectedDates;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _posting = widget.posting;
    _loadBookedDates();
  }

  initializeStripePaymentSheet(int paymentAmount) async {
    try {
      final data = await createPaymentIntent(
        name: AppConstants.currentUser.getFullName(),
        address: _posting!.address!,
        amount: (paymentAmount * 100).toString(),
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Otel ve Emlak Kiralama',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      CommonFunctions.showSnackBar(context, "Ödeme ayarı başarısız oldu: $e");

      rethrow;
    }
  }

  _makeBookingForPropertyListing() async {
    if(_selectedDates.isEmpty){return;}

    int totalAmount = (_posting!.price! * _selectedDates.length).round();

    await initializeStripePaymentSheet(totalAmount);

    try {
      await Stripe.instance.presentPaymentSheet();

      _posting!.saveBookingData(_selectedDates, context, totalAmount, _posting!.host!.id!).whenComplete(()
      {
        Navigator.pop(context);
      });
    }
    catch (error) {
      CommonFunctions.showSnackBar(context, "Online ödeme başarısız oldu: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rezervasyon ${_posting!.name}"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Paz'),
                Text('Pzt'),
                Text('Salı'),
                Text('Car'),
                Text('Per'),
                Text('Cum'),
                Text('Cmt'),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: (_calendarWidgets.isEmpty) ? Container() : PageView.builder(
                itemCount: _calendarWidgets.length,
                itemBuilder: (context, index) {
                  return _calendarWidgets[index];
                },
              ),
            ),

            MaterialButton(
              onPressed: () {
                _makeBookingForPropertyListing();
              },
              minWidth: double.infinity,
              height: MediaQuery.of(context).size.height / 16,
              color: Colors.green,
              child: const Text('Şimdi Rezervasyon Yap', style: TextStyle(fontSize: 20),),
            ),
          ],
        ),
      ),
    );
  }
}
