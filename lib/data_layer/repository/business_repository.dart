import 'package:geosocial/common/failures/server_failure.dart';
import 'package:geosocial/data_layer/data_sources/network/graphql/graphql_client.dart';
import 'package:geosocial/data_layer/data_sources/network/graphql/queries/graphql_queries.graphql.dart';
import 'package:geosocial/data_layer/entities/business.dart';
import 'package:geosocial/data_layer/entities/filter_dto.dart';
import 'package:geosocial/data_layer/services/location_service/location_service.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

class GetBusinessesRequestFailure implements Exception {}

abstract class BusinessRepository {
  Future<List<Business>> getBusinesses(FilterDTO filter, int limit, int offset);
  Future<Either<ServerFailure, Business>> getBusinessDetail(String id);
}

@LazySingleton(as: BusinessRepository)
class BusinessRepositoryImpl extends BusinessRepository {
  final LocationService _locationService;
  final GraphQLService _graphQl;

  BusinessRepositoryImpl(this._graphQl, this._locationService);

  Future<List<Business>> getBusinesses(
      FilterDTO filter, int limit, int offset) async {
    final location = filter.useMyLocation ? null : filter.location;
    var longitude;
    var latitude;

    if (filter.useMyLocation) {
      final positionOrFailrue = await _locationService.getCurrentPosition();
      positionOrFailrue.fold(
        (failure) => {
          //ignored, failure should never occur
        },
        (position) {
          longitude = position.longitude;
          latitude = position.latitude;
        },
      );
    }

    final result = await _graphQl.execute(
      SearchBusinessesQuery(
        variables: SearchBusinessesArguments(
            location: location,
            latitude: latitude,
            longitude: longitude,
            searchTerm: filter.filterQuery,
            categories: filter.categoriesString(),
            price: filter.priceLevelToString(),
            radius: filter.radius,
            limit: limit,
            offset: offset),
      ),
    );

    final data = result.data['search']['business'] as List;
    final businesses = data.map((e) => Business.fromJson(e)).toList();

    return businesses;
  }

  @override
  Future<Either<ServerFailure, Business>> getBusinessDetail(String id) async {
    final result = await _graphQl.execute(
      BusinessDetailQuery(
        variables: BusinessDetailArguments(id: id),
      ),
    );
    if (result.hasException) {
      return left(ServerFailure.serverError());
    }

    final business = Business.fromJson(result.data['business']);
    return right(business);
  }
}