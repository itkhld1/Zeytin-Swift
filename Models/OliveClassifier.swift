import CoreML

/// Model Prediction Input Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, visionOS 1.0, *)
@available(watchOS, unavailable)
public class OliveClassifierInput : MLFeatureProvider {

    public var image: CVPixelBuffer

    public var featureNames: Set<String> { ["image"] }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }

    public init(image: CVPixelBuffer) {
        self.image = image
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public convenience init(imageWith image: CGImage) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public convenience init(imageAt image: URL) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 299, pixelsHigh: 299, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!
    }
}

/// Model Prediction Output Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, visionOS 1.0, *)
@available(watchOS, unavailable)
public class OliveClassifierOutput : MLFeatureProvider {

    private let provider : MLFeatureProvider

    public var target: String {
        provider.featureValue(for: "target")!.stringValue
    }

    public var targetProbability: [String : Double] {
        provider.featureValue(for: "targetProbability")!.dictionaryValue as! [String : Double]
    }

    public var featureNames: Set<String> {
        provider.featureNames
    }

    public func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    public init(target: String, targetProbability: [String : Double]) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["target" : MLFeatureValue(string: target), "targetProbability" : MLFeatureValue(dictionary: targetProbability as [AnyHashable : NSNumber])])
    }

    public init(features: MLFeatureProvider) {
        self.provider = features
    }
}

/// Class for model loading and prediction
@available(macOS 10.14, iOS 12.0, tvOS 12.0, visionOS 1.0, *)
@available(watchOS, unavailable)
public class OliveClassifier {
    public let model: MLModel

    public class var urlOfModelInThisBundle : URL {
        // Updated for Swift Playgrounds compatibility
        let sourceUrl = Bundle.main.url(forResource: "OliveClassifier", withExtension: "model")!
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("OliveClassifier.mlmodel")
        try? FileManager.default.removeItem(at: tempUrl)
        try! FileManager.default.copyItem(at: sourceUrl, to: tempUrl)
        return try! MLModel.compileModel(at: tempUrl)
    }

    public init(model: MLModel) {
        self.model = model
    }

    @available(*, deprecated, message: "Use init(configuration:) instead.")
    public convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    public convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    public convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    public convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    public class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<OliveClassifier, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> OliveClassifier {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    public class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<OliveClassifier, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(OliveClassifier(model: model)))
            }
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> OliveClassifier {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return OliveClassifier(model: model)
    }

    public func prediction(input: OliveClassifierInput) throws -> OliveClassifierOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }

    public func prediction(input: OliveClassifierInput, options: MLPredictionOptions) throws -> OliveClassifierOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return OliveClassifierOutput(features: outFeatures)
    }

    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    public func prediction(input: OliveClassifierInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> OliveClassifierOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return OliveClassifierOutput(features: outFeatures)
    }

    public func prediction(image: CVPixelBuffer) throws -> OliveClassifierOutput {
        let input_ = OliveClassifierInput(image: image)
        return try prediction(input: input_)
    }

    public func predictions(inputs: [OliveClassifierInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [OliveClassifierOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [OliveClassifierOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  OliveClassifierOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
