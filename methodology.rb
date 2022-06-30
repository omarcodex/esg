# This is a working draft of an open methodology for calculating
# the environmental component of Environmental, Social, and Governance (ESG)
# ratings. It is intended to demonstrate transparency and rely upon the best
# available information to be furnished, eventually, by external and expert
# sources.

# The weightings can be adjusted to look at sensitivity of the results.
# Data sources can be either in-house or external (APIs that may not exist).

class APICaller
    attr_reader :name
    def self.global_water_footprint
      return { "value" => "0.75"}
    end
  end
  
  API_MAP =
    {
      "water_score" => "global_water_footprint"
    }
  
  API_INDEX =
    {
      "global_water_footprint" => APICaller.global_water_footprint
    }
  
  WEIGHT_DEFAULT_MAP =
    {
      "climate_weighting" => 0.70,
      "land_weighting" => 0.2,
      "water_weighting" => 0.2
    }
  
  SCORE_DEFAULT_MAP =
    {
      "climate_score" => 100,
      "land_score" => 100,
      "water_score" => 20
    }
  
  enviro_weighting_method_map =
      {
        "climate_weighting" => "default",
        "land_weighting" => "default",
        "water_weighting" => "default"
      }
  
  enviro_score_method_map =
      { "climate_score" => "default",
        "land_score" => "default",
        "water_score" => "API"
      }
  
  enviro_score_outputs =
    {
      "climate_weighting" => 0,
      "land_weighting" => 0,
      "water_weighting" => 0,
      "climate_score" => 0,
      "land_score" => 0,
      "water_score" => 0
    }
  
  def gather_info(input_hash, output_hash)
    output_hash ||= {}
    input_hash.each do |name, data_source|
      if data_source == "default"
        if name.include?("weight")
          score = WEIGHT_DEFAULT_MAP[name]
        elsif name.include?("score")
          score = SCORE_DEFAULT_MAP[name]
        end
      elsif data_source == "API"
        api_to_call = API_MAP[name]
        called_api = API_INDEX[api_to_call]
        score = called_api["value"].to_f
      end
      output_hash[name] = score
    end
  end
  
  def convert_to_grade(score)
    case score
    when (90..100)
      "A"
    when (80..89)
      "B"
    when (70..79)
      "C"
    when (60..69)
      "D"
    else
      "F"
    end
  end
  
  puts "Retrieving weights..."
  gather_info(enviro_weighting_method_map, enviro_score_outputs)
  
  puts "Retrieving scores..."
  gather_info(enviro_score_method_map, enviro_score_outputs)
  
  puts "Calculating overall score..."
  environ_score = [
      enviro_score_outputs["climate_weighting"] * enviro_score_outputs["climate_score"],
      enviro_score_outputs["land_weighting"] * enviro_score_outputs["land_score"],
      enviro_score_outputs["water_weighting"] * enviro_score_outputs["water_score"]
    ].inject(0, :+) # sum method may be deprecated depending on Ruby version
  
  puts """
  Final score is: #{environ_score}.
  Equals a grade of: #{convert_to_grade(environ_score)}.
  """