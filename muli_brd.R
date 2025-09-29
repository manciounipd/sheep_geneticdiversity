# Define the breeds
abbrv=function () {
breeds <- c("AfecAssaf", "AfricanDorper", "AfricanWhiteDorper", "Afshari", "Alpagota", "Altamurana", 
            "Arawapa", "AustralianCoopworth", "AustralianIndustryMerino", "AustralianMerino", 
            "AustralianPollDorset", "AustralianPollMerino", "AustralianSuffolk", "BangladeshiBGE", 
            "BangladeshiGarole", "BarbadosBlackBelly", "BlackHeadedMountain", "BorderLeicester", 
            "Boreray", "BrazilianCreole", "Brogna", "BundnerOberlanderSheep", "Castellana", 
            "Changthangi", "ChineseMerino", "Chios", "Churra", "Comisana", "CyprusFatTail", 
            "Deccani", "DorsetHorn", "EastFriesianBrown", "EastFriesianWhite", "EgyptianBarki", 
            "EngadineRedSheep", "EthiopianMenz", "Finnsheep", "Foza", "Galway", "Garut", 
            "GermanTexel", "GulfCoastNative", "Icelandic", "ImprovedAwassi", "IndianGarole", 
            "IrishSuffolk", "Karakas", "Lamon", "Leccese", "LocalAwassi", "MacarthurMerino", 
            "MeatLacaune", "Merinolandschaf", "MilkLacaune", "Moghani", "MoradaNova", 
            "NamaquaAfrikaner", "NewZealandRomney", "NewZealandTexel", "Norduz", "Ojalada", 
            "OldNorwegianspaelsau", "Qezel", "Rambouillet", "Rasaaragonesa", "RedMaasai", 
            "RonderibAfrikaner", "Sakiz", "SantaInes", "SardinianAncestralBlack", "ScottishBlackface", 
            "ScottishTexel", "Soay", "Spael-coloured", "Spael-white", "SriLankan", "StElizabeth", 
            "Sumatra", "SwissBlack-BrownMountainSheep", "SwissMirrorSheep", "SwissWhiteAlpineSheep", 
            "Tibetan", "ValaisBlacknoseSheep", "ValaisRedSheep", "Wiltshire")

# Create a function to generate unique 3-letter abbreviations
generate_unique_abbreviation <- function(breed, existing_abbrs) {
  words <- strsplit(breed, "(?=[A-Z])", perl = TRUE)[[1]]
  base_abbr <- if (length(words) > 1) {
    toupper(paste0(substr(words[1], 1, 1), substr(words[2], 1, 1), substr(words[3], 1, 1)))
  } else {
    toupper(substr(breed, 1, 3))
  }
  
  if (nchar(base_abbr) < 3) {
    base_abbr <- paste0(base_abbr, substr(breed, nchar(base_abbr) + 1, 3 - nchar(base_abbr)))
  }
  
  if (base_abbr %in% existing_abbrs) {
    i <- 1
    while(paste0(base_abbr, i) %in% existing_abbrs) {
      i <- i + 1
    }
    base_abbr <- paste0(base_abbr, i)
  }
  
  return(base_abbr)
}

# Create a function to assign continent based on breed characteristics
assign_continent <- function(breed) {
  if (grepl("Australian|NewZealand", breed)) {
    return("Oceania")
  } else if (grepl("African|Egyptian|Ethiopian|RedMaasai", breed)) {
    return("Africa")
  } else if (grepl("Brazilian|SantaInes", breed)) {
    return("South America")
  } else if (grepl("GulfCoast|Rambouillet|Barbados|StElizabeth", breed)) {
    return("North America")
  } else if (grepl("Chinese|Bangladeshi|Indian|Changthangi|Garut|Sumatra|Tibetan|Karakas|Moghani|Qezel|Sakiz|SriLankan|Awassi|Afshari", breed)) {
    return("Asia")
  } else {
    return("Europe")  # Default to Europe for remaining breeds
  }
}

# Generate unique abbreviations
abbreviations <- character(length(breeds))
for (i in seq_along(breeds)) {
  abbreviations[i] <- generate_unique_abbreviation(breeds[i], abbreviations[1:(i-1)])
}

# Create a data frame to store breed information
breed_data <- data.frame(
  Abbreviation = abbreviations,
  FullName = breeds,
  Continent = sapply(breeds, assign_continent),
  stringsAsFactors = FALSE
)

# Set the row names to be the abbreviations
rownames(breed_data) <- breed_data$Abbreviation

# Print the result
return(breed_data)
}



give_me_contenet=function() {


breeds <- c("AfecAssaf", "AfricanDorper", "AfricanWhiteDorper", "Afshari", "Alpagota", "Altamurana", 
            "Arawapa", "AustralianCoopworth", "AustralianIndustryMerino", "AustralianMerino", 
            "AustralianPollDorset", "AustralianPollMerino", "AustralianSuffolk", "BangladeshiBGE", 
            "BangladeshiGarole", "BarbadosBlackBelly", "BlackHeadedMountain", "BorderLeicester", 
            "Boreray", "BrazilianCreole", "Brogna", "BundnerOberlanderSheep", "Castellana", 
            "Changthangi", "ChineseMerino", "Chios", "Churra", "Comisana", "CyprusFatTail", 
            "Deccani", "DorsetHorn", "EastFriesianBrown", "EastFriesianWhite", "EgyptianBarki", 
            "EngadineRedSheep", "EthiopianMenz", "Finnsheep", "Foza", "Galway", "Garut", 
            "GermanTexel", "GulfCoastNative", "Icelandic", "ImprovedAwassi", "IndianGarole", 
            "IrishSuffolk", "Karakas", "Lamon", "Leccese", "LocalAwassi", "MacarthurMerino", 
            "MeatLacaune", "Merinolandschaf", "MilkLacaune", "Moghani", "MoradaNova", 
            "NamaquaAfrikaner", "NewZealandRomney", "NewZealandTexel", "Norduz", "Ojalada", 
            "OldNorwegianspaelsau", "Qezel", "Rambouillet", "Rasaaragonesa", "RedMaasai", 
            "RonderibAfrikaner", "Sakiz", "SantaInes", "SardinianAncestralBlack", "ScottishBlackface", 
            "ScottishTexel", "Soay", "Spael-coloured", "Spael-white", "SriLankan", "StElizabeth", 
            "Sumatra", "SwissBlack-BrownMountainSheep", "SwissMirrorSheep", "SwissWhiteAlpineSheep", 
            "Tibetan", "ValaisBlacknoseSheep", "ValaisRedSheep", "Wiltshire")
# Create a function to assign continent based on breed characteristics
assign_continent <- function(breed) {
  if (grepl("Australian|NewZealand", breed)) {
    return("Oceania")
  } else if (grepl("African|Egyptian|Ethiopian|RedMaasai", breed)) {
    return("Africa")
  } else if (grepl("Brazilian|SantaInes", breed)) {
    return("South America")
  } else if (grepl("GulfCoast|Rambouillet|Barbados|StElizabeth", breed)) {
    return("North America")
  } else if (grepl("Chinese|Bangladeshi|Indian|Changthangi|Garut|Sumatra|Tibetan|Karakas|Moghani|Qezel|Sakiz|SriLankan|Awassi|Afshari", breed)) {
    return("Asia")
  } else {
    return("Europe")  # Default to Europe for remaining breeds
  }
}

# Create an empty list to store breeds by continent
breeds_by_continent <- list()

# Assign each breed to its continent
for (breed in breeds) {
  continent <- assign_continent(breed)
  if (is.null(breeds_by_continent[[continent]])) {
    breeds_by_continent[[continent]] <- c()
  }
  breeds_by_continent[[continent]] <- c(breeds_by_continent[[continent]], breed)
}

# Print the result
return(breeds_by_continent)
}














organize_breeds_by_country <- function(breeds) {
  # Function to assign country or region
  assign_country <- function(breed) {
    if (grepl("Australian", breed)) return("Australia")
    if (grepl("NewZealand", breed)) return("New Zealand")
    if (grepl("African|Namaqua|Ronderib|Dorper", breed)) return("South Africa")
    if (grepl("Bangladeshi", breed)) return("Bangladesh")
    if (grepl("Barbados", breed)) return("Barbados")
    if (grepl("Brazilian|SantaInes|MoradaNova", breed)) return("Brazil")
    if (grepl("Chinese|Tibetan", breed)) return("China")
    if (grepl("Cyprus", breed)) return("Cyprus")
    if (grepl("Egyptian", breed)) return("Egypt")
    if (grepl("Ethiopian", breed)) return("Ethiopia")
    if (grepl("Finnish|Finnsheep", breed)) return("Finland")
    if (grepl("German|Merinolandschaf", breed)) return("Germany")
    if (grepl("Icelandic", breed)) return("Iceland")
    if (grepl("Indian|Deccani|Changthangi", breed)) return("India")
    if (grepl("Irish", breed)) return("Ireland")
    if (grepl("Garut|Sumatra", breed)) return("Indonesia")
    if (grepl("Awassi", breed)) return("Israel")
    if (grepl("Altamurana|Comisana|Leccese|Brogna|Lamon|Foza|SardinianAncestralBlack|Alpagota", breed)) return("Italy")
    if (grepl("Karakas|Norduz|Sakiz", breed)) return("Turkey")
    if (grepl("Lacaune", breed)) return("France")
    if (grepl("Norwegian|Spael", breed)) return("Norway")
    if (grepl("Castellana|Churra|Ojalada|Rasaaragonesa", breed)) return("Spain")
    if (grepl("Swiss|Bundner|Engadine|Valais", breed)) return("Switzerland")
    if (grepl("Galway", breed)) return("Ireland")
    if (grepl("Scottish|Boreray|Soay", breed)) return("Scotland")
    if (grepl("Wiltshire|DorsetHorn|BorderLeicester", breed)) return("England")
    if (grepl("SriLankan", breed)) return("Sri Lanka")
    if (grepl("StElizabeth", breed)) return("Jamaica")
    if (grepl("RedMaasai", breed)) return("Kenya")
    if (grepl("Afshari|Moghani|Qezel", breed)) return("Iran")
    if (grepl("GulfCoast|Rambouillet", breed)) return("United States")
    if (grepl("Chios", breed)) return("Greece")
    return("Unknown")
  }

  # Assign countries to breeds
  breed_countries <- sapply(breeds, assign_country)

  # Create a list of breeds by country
  breeds_by_country <- split(breeds, breed_countries)

  # Sort the list alphabetically by country name
  breeds_by_country <- breeds_by_country[order(names(breeds_by_country))]

  # Create a summary
  summary <- list(
    total_breeds = length(breeds),
    total_countries = length(breeds_by_country),
    top_countries = sort(table(breed_countries), decreasing = TRUE)[1:5]
  )

  # Return both the organized breeds and the summary
  return(list(
    breeds_by_country = breeds_by_country,
    summary = summary
  ))
}

# Example usage:
breeds <- c("AfecAssaf", "AfricanDorper", "AfricanWhiteDorper", "Afshari", "Alpagota", "Altamurana", 
            "Arawapa", "AustralianCoopworth", "AustralianIndustryMerino", "AustralianMerino", 
            "AustralianPollDorset", "AustralianPollMerino", "AustralianSuffolk", "BangladeshiBGE", 
            "BangladeshiGarole", "BarbadosBlackBelly", "BlackHeadedMountain", "BorderLeicester", 
            "Boreray", "BrazilianCreole", "Brogna", "BundnerOberlanderSheep", "Castellana", 
            "Changthangi", "ChineseMerino", "Chios", "Churra", "Comisana", "CyprusFatTail", 
            "Deccani", "DorsetHorn", "EastFriesianBrown", "EastFriesianWhite", "EgyptianBarki", 
            "EngadineRedSheep", "EthiopianMenz", "Finnsheep", "Foza", "Galway", "Garut", 
            "GermanTexel", "GulfCoastNative", "Icelandic", "ImprovedAwassi", "IndianGarole", 
            "IrishSuffolk", "Karakas", "Lamon", "Leccese", "LocalAwassi", "MacarthurMerino", 
            "MeatLacaune", "Merinolandschaf", "MilkLacaune", "Moghani", "MoradaNova", 
            "NamaquaAfrikaner", "NewZealandRomney", "NewZealandTexel", "Norduz", "Ojalada", 
            "OldNorwegianspaelsau", "Qezel", "Rambouillet", "Rasaaragonesa", "RedMaasai", 
            "RonderibAfrikaner", "Sakiz", "SantaInes", "SardinianAncestralBlack", "ScottishBlackface", 
            "ScottishTexel", "Soay", "Spael-coloured", "Spael-white", "SriLankan", "StElizabeth", 
            "Sumatra", "SwissBlack-BrownMountainSheep", "SwissMirrorSheep", "SwissWhiteAlpineSheep", 
            "Tibetan", "ValaisBlacknoseSheep", "ValaisRedSheep", "Wiltshire")

result <- organize_breeds_by_country(breeds)
