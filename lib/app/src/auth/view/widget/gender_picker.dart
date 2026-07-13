import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/src/auth/bloc/auth_bloc.dart';


class GenderPicker extends StatefulWidget {
  const GenderPicker({
    super.key,
  });

  @override
  State<GenderPicker> createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {
  String? pickedGender;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _authBloc.add(FetchingGenderListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _authBloc,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (AuthLoadingState):
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          case const (AuthGenderListFetchingLoadedSuccessState):
            final blocSnapshot =
                (state as AuthGenderListFetchingLoadedSuccessState)
                    .genderEntity;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Gender',
                    style: grey14RegularTextStyle,
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: blocSnapshot.record!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          pickedGender =
                              blocSnapshot.record![index].genderID.toString();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              blocSnapshot.record![index].genderName.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );

          case const (AuthGenderListFetchingFailedErrorState):
            final error =
                (state as AuthGenderListFetchingFailedErrorState).error;
            return Center(
              child: Text(error),
            );
          default:
            return Center(
              child: Text('State not found'),
            );
        }
      },
    );
  }
}
