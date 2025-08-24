import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/provider.dart';

part 'provider_model.g.dart';

/// 提供商响应模型
@JsonSerializable()
class ProvidersResponseModel {
  const ProvidersResponseModel({
    required this.providers,
    required this.defaultModels,
  });

  final List<ProviderModel> providers;
  @JsonKey(name: 'default')
  final Map<String, String> defaultModels;

  factory ProvidersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProvidersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProvidersResponseModelToJson(this);

  /// 转换为领域实体
  ProvidersResponse toDomain() {
    return ProvidersResponse(
      providers: providers.map((p) => p.toDomain()).toList(),
      defaultModels: defaultModels,
    );
  }
}

/// 提供商模型
@JsonSerializable()
class ProviderModel {
  const ProviderModel({
    required this.id,
    required this.name,
    required this.env,
    this.api,
    this.npm,
    required this.models,
  });

  final String id;
  final String name;
  final List<String> env;
  final String? api;
  final String? npm;
  final Map<String, ModelModel> models;

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderModelToJson(this);

  /// 转换为领域实体
  Provider toDomain() {
    return Provider(
      id: id,
      name: name,
      env: env,
      api: api,
      npm: npm,
      models: models.map((key, value) => MapEntry(key, value.toDomain())),
    );
  }
}

/// AI模型模型
@JsonSerializable()
class ModelModel {
  const ModelModel({
    required this.id,
    required this.name,
    required this.releaseDate,
    required this.attachment,
    required this.reasoning,
    required this.temperature,
    required this.toolCall,
    required this.cost,
    required this.limit,
    this.options = const {},
    this.knowledge,
    this.lastUpdated,
    this.modalities,
    this.openWeights,
  });

  final String id;
  final String name;
  @JsonKey(name: 'release_date')
  final String releaseDate;
  final bool attachment;
  final bool reasoning;
  final bool temperature;
  @JsonKey(name: 'tool_call')
  final bool toolCall;
  final ModelCostModel cost;
  final ModelLimitModel limit;
  final Map<String, dynamic>? options;
  final String? knowledge;
  @JsonKey(name: 'last_updated')
  final String? lastUpdated;
  final Map<String, dynamic>? modalities;
  @JsonKey(name: 'open_weights')
  final bool? openWeights;

  factory ModelModel.fromJson(Map<String, dynamic> json) =>
      _$ModelModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelModelToJson(this);

  /// 转换为领域实体
  Model toDomain() {
    return Model(
      id: id,
      name: name,
      releaseDate: releaseDate,
      attachment: attachment,
      reasoning: reasoning,
      temperature: temperature,
      toolCall: toolCall,
      cost: cost.toDomain(),
      limit: limit.toDomain(),
      options: options ?? {},
      knowledge: knowledge,
      lastUpdated: lastUpdated,
      modalities: modalities,
      openWeights: openWeights,
    );
  }
}

/// 模型费用模型
@JsonSerializable()
class ModelCostModel {
  const ModelCostModel({
    required this.input,
    required this.output,
    this.cacheRead,
    this.cacheWrite,
  });

  @JsonKey(fromJson: _doubleFromJson)
  final double input;
  @JsonKey(fromJson: _doubleFromJson)
  final double output;
  @JsonKey(name: 'cache_read', fromJson: _nullableDoubleFromJson)
  final double? cacheRead;
  @JsonKey(name: 'cache_write', fromJson: _nullableDoubleFromJson)
  final double? cacheWrite;

  static double _doubleFromJson(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _nullableDoubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory ModelCostModel.fromJson(Map<String, dynamic> json) =>
      _$ModelCostModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCostModelToJson(this);

  /// 转换为领域实体
  ModelCost toDomain() {
    return ModelCost(
      input: input,
      output: output,
      cacheRead: cacheRead,
      cacheWrite: cacheWrite,
    );
  }
}

/// 模型限制模型
@JsonSerializable()
class ModelLimitModel {
  const ModelLimitModel({required this.context, required this.output});

  final int context;
  final int output;

  factory ModelLimitModel.fromJson(Map<String, dynamic> json) =>
      _$ModelLimitModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelLimitModelToJson(this);

  /// 转换为领域实体
  ModelLimit toDomain() {
    return ModelLimit(context: context, output: output);
  }
}
