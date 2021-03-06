module SquidAnalyzer
  class SceneDetector
    def initialize(scene_class:, score_threshold:, template_image_path:)
      @scene_class = scene_class
      @score_threshold = score_threshold
      @template_image_path = template_image_path
    end

    # @param image [OpenCV::IplImage]
    # @return [SquidAnalyzer::Scenes::Base, nil]
    def call(image)
      Detection.new(
        image: image,
        scene_class: @scene_class,
        score_threshold: @score_threshold,
        template_image: template_image,
      ).call
    end

    private

    # @return [OpenCV::IplImage]
    def template_image
      @template_image ||= ::OpenCV::IplImage.load(@template_image_path)
    end

    class Detection
      def initialize(
        image:,
        scene_class:,
        score_threshold:,
        template_image:
      )
        @image = image
        @scene_class = scene_class
        @score_threshold = score_threshold
        @template_image = template_image
      end

      # @return [SquidAnalyzer::Scenes::Base, nil]
      def call
        if matched?
          @scene_class.new(@image)
        end
      end

      private

      # @return [false, true]
      def matched?
        score >= @score_threshold
      end

      # @return [Float]
      def score
        @image.match_template(@template_image, ::OpenCV::CV_TM_CCORR_NORMED).min_max_loc[1]
      end
    end
  end
end
