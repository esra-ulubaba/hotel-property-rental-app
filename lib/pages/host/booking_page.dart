import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/models/posting_objects.dart';
import 'package:otel_ve_emlak_kiralama/widgets/calendar_view_ui.dart';
import 'package:otel_ve_emlak_kiralama/widgets/show_my_posting_list_tile.dart';

class BookingsPage extends StatefulWidget {
  static final String routeName = '/bookingsPageRoute';
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<DateTime> _bookedDates = [];
  List<DateTime> _allBookedDates = [];
  Posting? _selectedPosting;

  @override
  void initState() {
    super.initState();

    _bookedDates = AppConstants.currentUser.getAllBookedDates();
    _allBookedDates = AppConstants.currentUser.getAllBookedDates();
  }

  _selectDate(DateTime date) {}

  List<DateTime> _getSelectedDates() {
    return [];
  }

  _clearSelectedPosting() {
    _bookedDates = _allBookedDates;
    _selectedPosting = null;

    setState(() {});
  }

  _selectAPosting(Posting posting) {
    _selectedPosting = posting;
    _bookedDates = posting.getAllBookedDates();

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const <Widget>[
                Text('Paz'),
                Text('Pzt'),
                Text('Salı'),
                Text('Crs'),
                Text('Per'),
                Text('Cuma'),
                Text('Cmt'),
              ],
            ),

            /// Calendar
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 25),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.8,
                child: PageView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return CalenderViewUi(
                      monthIndex: index,
                      bookedDates: _bookedDates,
                      selectDate: _selectDate,
                      getSelectedDates: _getSelectedDates,
                    );
                  },
                ),
              ),
            ),

            /// Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'İlana göre filtrele',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSelectedPosting,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      'Sıfırla',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            /// Postings List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppConstants.currentUser.myPostings!.length,
              itemBuilder: (context, index) {
                final posting = AppConstants.currentUser.myPostings![index];
                final bool isSelected = _selectedPosting == posting;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: InkWell(
                    onTap: () => _selectAPosting(posting),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade600,
                          width: isSelected ? 4.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ShowMyPostingListTile(posting: posting),
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
