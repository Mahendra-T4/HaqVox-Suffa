import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';

class FAQView extends StatefulWidget {
  const FAQView({super.key});
  static const String routeName = '/faq';

  @override
  State<FAQView> createState() => _FAQViewState();
}

class _FAQViewState extends State<FAQView> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I download books?',
      answer:
          'To download a book, simply navigate to the book details page and tap on the download button. The book will be saved to your device for offline reading.',
    ),
    FAQItem(
      question: 'Can I read books offline?',
      answer:
          'Yes! Once you have downloaded a book, you can access it anytime without an internet connection from your library.',
    ),
    FAQItem(
      question: 'How do I manage my subscription?',
      answer:
          'You can manage your subscription by going to Profile > Subscription. Here you can view your current plan, billing history, and make changes to your subscription.',
    ),
    FAQItem(
      question: 'What payment methods are accepted?',
      answer:
          'We accept various payment methods including credit/debit cards, PayPal, and Google Pay for secure and convenient transactions.',
    ),
    FAQItem(
      question: 'How do I contact support?',
      answer:
          'You can reach our support team through the Help Center or by emailing support@suffa.com. We typically respond within 24 hours.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InternetConnectionService().connectionStream,
      initialData: true, // Assume connected initially
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const MySpace();
        }

        // Handle disconnected state
        if (snapshot.data == false) {
          return const MySpace();
        }

        // Handle loading state
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                color: whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: whiteColor),
              onPressed: () => Navigator.pop(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(fixPadding * 2.0),
            children: [
              Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find answers to common questions below',
                style: grey14RegularTextStyle,
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqItems.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(_faqItems[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            item.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          iconColor: primaryColor,
          textColor: Colors.black87,
          childrenPadding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                item.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
