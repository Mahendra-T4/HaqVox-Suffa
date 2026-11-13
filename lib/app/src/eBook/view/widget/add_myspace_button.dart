import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/myspace/bloc/my_space_bloc.dart';
import 'package:haqvox/app/src/screens.dart';

class AddMySpaceButton extends StatelessWidget {
  const AddMySpaceButton({
    super.key,
    required this.audioSlug,
    required this.mySpaceType,
    required this.audioBookmarked,
    this.successCallback,
  });
  final String audioSlug;
  final String mySpaceType;
  final int audioBookmarked;
  final Function()? successCallback;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MySpaceBloc(),
      child: BlocConsumer<MySpaceBloc, MySpaceState>(
        listener: (context, state) {
          if (state is AddMySpaceLoadedSuccessState) {
            if (state.addOnMySpaceEntity.status == 1) {
              successCallback?.call();
            } else {
              CustomSnackBar.show(
                context: context,
                message: state.addOnMySpaceEntity.message.toString(),
                type: SnackBarType.error,
              );
            }
          } else if (state is AddMySpaceFailedErrorState) {
            CustomSnackBar.show(
              context: context,
              message: state.error,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is MySpaceLoadingState) {
            return const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                BlocProvider.of<MySpaceBloc>(context).add(
                  AddOnMySpaceEvent(
                    audioSlug: audioSlug,
                    mySpaceType: mySpaceType,
                    context: context,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  audioBookmarked == 1
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
