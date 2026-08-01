import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/view_posting_page.dart';
import 'package:otel_ve_emlak_kiralama/widgets/posting_grid_tile.dart';

import '../../models/posting_objects.dart';


class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchText = _controller.text.toLowerCase();

    return Padding(
      padding: EdgeInsets.fromLTRB(25, 15, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [

            ///  Search Bar
            TextField(
              controller: _controller,
              onChanged: (c) {
                setState(() {});  //refresh when typing
              },
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Yer adına, şehre, mülk türüne... göre arama yapın.',
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Tüm İlanları Görüntüle - Arama Metni mevcutsa (Arama ile Filtrelenmiş)
            StreamBuilder<QuerySnapshot>(
              stream: searchText.isEmpty
                  ? FirebaseFirestore.instance.collection('postings').snapshots()
                  : FirebaseFirestore.instance
                  .collection('postings')
                  .where(
                Filter.or(
                  //  İsme göre arama
                  Filter('name', isGreaterThanOrEqualTo: searchText),
                  Filter('name', isLessThanOrEqualTo: '$searchText\uf8ff'), //Ali diye yazıldığında Ali, Alice, Alina... diye öneri verecek

                  //  Adrese göre arama
                  Filter('address', isGreaterThanOrEqualTo: searchText),
                  Filter('address', isLessThanOrEqualTo: '$searchText\uf8ff'),

                  //  Türe göre arama
                  Filter('type', isGreaterThanOrEqualTo: searchText),
                  Filter('type', isLessThanOrEqualTo: '$searchText\uf8ff'),
                ),
              )
                  .snapshots(),
              builder: (context, snapshots) {
                if (!snapshots.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshots.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        'Sonuç bulunamadı',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 15,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final posting = Posting(id: doc.id);
                    posting.getPostingInfoFromSnapshot(doc);

                    return InkWell(
                      onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPostingPage(posting: posting)));
                      },
                      child: PostingGridTile(posting: posting),
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
