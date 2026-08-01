import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/models/posting_objects.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/view_posting_page.dart';

import '../../widgets/grid_widget_ui.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.only(top:25),
              child: Text(
                'Yaklaşan Seyahatler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:15, bottom:25),
              child: SizedBox(
                height: MediaQuery.of(context).size.height/3,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: AppConstants.currentUser.getUpcomingTrips().length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    Booking currentBooking = AppConstants.currentUser.getUpcomingTrips()[index];
                    return Padding(
                      padding: const EdgeInsets.only(right:15.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width/2.5,
                        child: InkResponse(
                          enableFeedback: true,
                          child: GridWidgetUi(booking: currentBooking,),
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewPostingPage(posting: currentBooking.posting!),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const Text(
              'Önceki Geziler',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:15, bottom:25),
              child: SizedBox(
                height: MediaQuery.of(context).size.height/3,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: AppConstants.currentUser.getPreviousTrips().length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    Booking currentBooking = AppConstants.currentUser.getPreviousTrips()[index];
                    return Padding(
                      padding: const EdgeInsets.only(right:15.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width/2.5,
                        child: InkResponse(
                          enableFeedback: true,
                          child: GridWidgetUi(booking: currentBooking,),
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewPostingPage(posting: currentBooking.posting!),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
