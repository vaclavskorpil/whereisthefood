import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geosocial/common/constants/dimens.dart';
import 'package:geosocial/data_layer/dependenci_injection/injector.dart';
import 'package:geosocial/data_layer/entities/category.dart';
import 'package:geosocial/domain/fitler/filter_cubit.dart';
import 'package:geosocial/domain/poi/poi_cubit.dart';

import 'package:geosocial/presentation/filter/category_card.dart';
import 'package:geosocial/presentation/styled_widgets/styled_snackbar.dart';

import 'package:geosocial/presentation/theme/my_colors.dart';

class FilterDialog extends StatelessWidget {
  final inputFieldPadding = const EdgeInsets.fromLTRB(
      0, Dimens.paddingMedium, 0, Dimens.paddingMedium);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocProvider<FilterCubit>(
        create: (context) => injector<FilterCubit>(),
        child: BlocListener<FilterCubit, FilterState>(
          listenWhen: (_, current) {
            return current.failure.isSome() || current.applyFilter;
          },
          listener: (context, state) {
            if (state.failure.isSome()) {
              // TODO properly handle state
              ScaffoldMessenger.of(context)
                  .showSnackBar(styledSnackBar("Something went wrong."));
            } else if (state.applyFilter) {
              //filter was sucesflully aplied, fetch new businesses
              context.read<POICubit>()..fetchNewBusinesses();
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.backgroundWhite,
                borderRadius: BorderRadius.circular(Dimens.cornerRadiusDefault),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Dimens.paddingBig),
                child: Column(
                  children: [
                    LocationInput(
                      inputFieldPadding: inputFieldPadding,
                    ),
                    FilterTermInput(inputFieldPadding: inputFieldPadding),
                    RadiusSlider(),
                    PriceLevel(),
                    const SizedBox(height: 10),
                    Categories(),
                    const SizedBox(height: 10),
                    ButtonRow()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LocationInput extends StatelessWidget {
  const LocationInput({
    Key key,
    @required this.inputFieldPadding,
  }) : super(key: key);

  final EdgeInsets inputFieldPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: inputFieldPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Filter"),
                BlocBuilder<FilterCubit, FilterState>(
                  buildWhen: (oldState, newState) =>
                      oldState.filter.location != newState.filter.location,
                  builder: (context, state) {
                    //is builded when location changed

                    return TextField(
                      controller: context
                          .read<FilterCubit>()
                          .locationTextEditingController,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (context) {
              var isLocationSelected = context.select(
                  (FilterCubit cubit) => cubit.state.filter.useMyLocation);
              //todo remve checkbox and put here togleable button
              return Checkbox(
                  value: isLocationSelected,
                  onChanged: (value) {
                    context.read<FilterCubit>()..useMyLocation(value);
                  });
            },
          ),
        ],
      ),
    );
  }
}

class FilterTermInput extends StatelessWidget {
  const FilterTermInput({
    Key key,
    @required this.inputFieldPadding,
  }) : super(key: key);

  final EdgeInsets inputFieldPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: inputFieldPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Filter"),
          Builder(
            builder: (context) {
              final searchTerm = context.select(
                  (FilterCubit cubit) => cubit.state.filter.filterQuery);
              return TextField(
                controller:
                    context.read<FilterCubit>().filterTextEditingController,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: OutlinedButton(
          onPressed: () {
            context.read<FilterCubit>()..applyFilter();
          },
          child: Text("Apply filter"),
        ))
      ],
    );
  }
}

class PriceLevel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final priceRange = context.select(
            (FilterCubit cubit) => cubit.state.filter.priceLevelRangeValue());

        return RangeSlider(
            max: 4,
            min: 1,
            divisions: 3,
            labels: RangeLabels(
              _priceLevelToText(priceRange.start),
              _priceLevelToText(priceRange.end),
            ),
            values: priceRange,
            onChanged: (priceLevel) {
              context.read<FilterCubit>()..changePriceLevel(priceLevel);
            });
      },
    );
  }

  static String _priceLevelToText(double _priceLevel) {
    var sb = "";
    for (int i = 0; i < _priceLevel; i++) {
      sb += "\$";
    }
    return sb;
  }
}

class Categories extends StatelessWidget {
  const Categories({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CategoryCard(
              Category("Restaurace", "rest"),
              Icons.restaurant,
            ),
            CategoryCard(
              Category("Drink", "rest"),
              Icons.local_drink,
            ),
            CategoryCard(
              Category("Víno", "rest"),
              Icons.restaurant,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CategoryCard(
        //       Category("Restaurace", "rest"),
        //       Icons.restaurant,
        //     ),
        //     CategoryCard(
        //       Category("Drink", "rest"),
        //       Icons.local_drink,
        //     ),
        //     CategoryCard(
        //       Category("Víno", "rest"),
        //       Icons.restaurant,
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 10),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CategoryCard(
        //       Category("Restaurace", "rest"),
        //       Icons.restaurant,
        //     ),
        //     CategoryCard(
        //       Category("Drink", "rest"),
        //       Icons.local_drink,
        //     ),
        //     CategoryCard(
        //       Category("Víno", "rest"),
        //       Icons.restaurant,
        //     ),
        //   ],
        // )
      ],
    );
  }
}

class RadiusSlider extends StatelessWidget {
  const RadiusSlider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Radius",
              textAlign: TextAlign.start,
            ),
            Builder(builder: (context) {
              final radius = context
                  .select((FilterCubit cubit) => cubit.state.filter.radius);

              return Text(
                "${radius.ceil()}m",
                textAlign: TextAlign.start,
              );
            }),
          ],
        ),
        Builder(builder: (context) {
          final radius =
              context.select((FilterCubit cubit) => cubit.state.filter.radius);

          return Slider(
            onChanged: (value) {
              context.read<FilterCubit>()..changeRadius(value);
            },
            min: 50,
            max: 20000,
            value: radius,
          );
        }),
      ],
    );
  }
}