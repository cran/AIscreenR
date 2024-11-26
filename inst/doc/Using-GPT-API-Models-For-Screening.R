## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  out.width = "100%",
  eval = FALSE
)

## ----eval = FALSE, warning=FALSE, message=FALSE-------------------------------
# # Loading packages
# library(AIscreenR) # Used to screen and calculate gpt vs. human performance
# library(synthesisr)  # Used to load RIS files
# library(tibble)    # Used to work with tibbles
# library(dplyr)     # Used to manipulate data
# library(purrr)     # For loops
# library(usethis)   # Used to add the API key the R environment (only relevant the first time you screen)
# library(future)    # Used to conduct screenings in parallel

## -----------------------------------------------------------------------------
# # NOTE: Find the RIS files behind this vignette at https://osf.io/kfbvu/
# 
# # Loading EXCLUDED studies
# ris_dat_excl <- read_refs("friends_excl.ris") |> # Add the path to your RIS file here
#   as_tibble() |>
#   select(author, eppi_id, title, abstract) |> # Using only relevant variables
#   mutate(
#     human_code = 0, #Tracking the human decision
#     across(c(author, title, abstract), ~ na_if(., "NA"))
#   )
# 
# ris_dat_excl
# #> # A tibble: 2,765 × 5
# #>   author                                                                eppi_id title abstract human_code
# #>   <chr>                                                                 <chr>   <chr> <chr>         <dbl>
# #> 1 Lovat C                                                               911525… "'Ba… "Postna…          0
# #> 2 Kohler Maxie                                                          911023… "\"F… "The ar…          0
# #> 3 Stevens Eleanor and Wood Jane                                         911020… "\"I… "'Non-o…          0
# #> 4 Essau C and Conradt J and Ederer E                                    915786… "[An…  NA               0
# #> 5 K<c3><a4>ssler P and Breme K                                          915784… "[Ev…  NA               0
# #> 6 Brubaker Ruth B and Bay Curt and Chacon Daniel W and Carson Madelein… 911523… "93 … "Introd…          0
# #> 7 Kumar Suresh and Vellymalay N                                         915785… "A C…  NA               0
# #> 8 Lock S                                                                915784… "A D…  NA               0
# #> 9 Bosco Nicolina and Giaccherini Susanna and Meringolo Patrizia         911019… "A g… "This a…          0
# #>10 Abd El Salam, Amira E and AbdAllah Amany M and El Maghawry Hala A     911017… "Eff… "Backgr…          0
# #># ℹ 2,755 more rows
# #># ℹ Use `print(n = ...)` to see more rows
# 
# # Loading INCLUDED studies
# ris_dat_incl <- read_refs("friends_incl.ris") |>
#   suppressWarnings() |>
#   as_tibble() |>
#   select(author, eppi_id, title, abstract) |>
#   mutate(
#     human_code = 1, #Tracking the human decision
#     across(c(author, title, abstract), ~ na_if(., "NA"))
#   )
# 
# ris_dat_incl
# #> # A tibble: 97 × 5
# #>   author                                                                eppi_id title abstract human_code
# #>   <chr>                                                                 <chr>   <chr> <chr>         <dbl>
# #> 1 G<c3><b6>kkaya Fu<cc><88>sun and Gedik Z                              915785… A Sc…  NA               1
# #> 2 ACTRN12607000254493                                                   911528… Long… "INTERV…          1
# #> 3 ACTRN12615000382572                                                   911528… The … "INTERV…          1
# #> 4 Ahlen Johan and Breitholtz Elisabeth and Barrett Paula M and Gallego… 911544… Scho… "Anxiet…          1
# #> 5 Ahlen Johan and Hursti Timo and Tanner Lindsey and Tokay Zelal and G… 911019… Prev… "Our st…          1
# #> 6 Green Sarah L                                                         915785… An e…  NA               1
# #> 7 Anticich Sarah A. J and Barrett Paula M and Silverman Wendy and Lach… 910111… The … "This s…          1
# #> 8 Barker Leslie Jayne                                                   915785… Prev…  NA               1
# #> 9 Barrett PM and Moore AF and Sonderegger R                             911527… The … "Young …          1
# #>10 Barrett PM and Shortt AL and Wescombe K                               911529… Exam…  NA               1
# #># ℹ 87 more rows
# #># ℹ Use `print(n = ...)` to see more rows

## ----eval = FALSE-------------------------------------------------------------
# set.seed(09042024)
# 
# excl_sample <-
#   ris_dat_excl |>
#   filter(!is.na(abstract)) |>
#   sample_references(150)
# 
# incl_sample <-
#   ris_dat_incl |>
#   filter(!is.na(abstract)) |>
#   sample_references(50)
# 
# test_dat <-
#   bind_rows(excl_sample, incl_sample) |>
#   mutate(
#     studyid = 1:n()
#   ) |>
#   relocate(studyid, .after = eppi_id)
# 
# 
# test_dat
# #>  # A tibble: 200 × 6
# #>   author             eppi_id studyid title abstract human_code
# #>   <chr>              <chr>     <int> <chr> <chr>         <dbl>
# #> 1 Moes and Frea Dou… 9433823       1 Usin… Studies…          0
# #> 2 Flemke Kimberly R  9432288       2 The … The pur…          0
# #> 3 Daniels M Harry a… 9431426       3 A Me… One of …          0
# #> 4 Schwartzman Mered… 9434093       4 Enha… New ana…          0
# #> 5 White Stuart F an… 9434418       5 Call… OBJECTI…          0
# #> 6 Chao-kai X U and … 9432240       6 A no… To deal…          0
# #> 7 Todd Thomas C      9434199       7 THE … This ar…          0
# #> 8 Kinoshita O and K… 9431762       8 Spec… BACKGRO…          0
# #> 9 Stratton Peter an… 9434563       9 Comp… This ar…          0
# #>10 Stevens Sally and… 9434158      10 Inte… The num…          0
# #># ℹ 190 more rows
# #># ℹ Use `print(n = ...)` to see more rows

## ----eval=TRUE, echo=FALSE, fig.cap='*Figure 1 - Generate API key from OpenAI*'----
knitr::include_graphics("helper-stuff/API_key_pic.png")

## -----------------------------------------------------------------------------
# # Run code to open your .Renviron file
# usethis::edit_r_environ()

## ----eval=TRUE, echo=FALSE, fig.cap='*Figure 2 - R environment file*'---------
knitr::include_graphics("helper-stuff/Renviron.png")

## ----eval=TRUE, echo=FALSE, fig.cap='*Figure 3 - Set API key*'----------------
knitr::include_graphics("helper-stuff/set_api.png")

## ----eval = FALSE-------------------------------------------------------------
# prompt <- "We are screening studies for a systematic literature review.
# The topic of the systematic review is the effect of the FRIENDS preventive programme
# on reducing anxiety symptoms in children and adolescents. The FRIENDS programme is a
# 10-session manualised  cognitive behavioural therapy (CBT) programme which can be
# used as both prevention and  treatment of child and youth anxiety.  The study should
# focus exclusively on this topic  and we are exclusively searching  for studies with
# a treatment and a comparison group.  For each study, I would like you to assess:
# 1) Is the study about the FRIENDS preventive programme?
# 2) Is the study estimating an effect between a treatment and control/comparison group?"

## ----eval=TRUE, echo=FALSE, fig.cap='*Figure 4 - Prompting in Word*'----------
knitr::include_graphics("helper-stuff/friends_prompt.png")

## -----------------------------------------------------------------------------
# word_path <-  system.file("extdata", "word_prompt_1.docx", package = "AIscreenR")
# 
# prompt <-
#   readtext::readtext(word_path)$text |>
#       stringr::str_remove_all("\n")

## ----message=FALSE, eval=FALSE------------------------------------------------
# # Gets information about whether you have access to a given model and
# # how many requests per minutes you are allow to send.
# models_rpm <- rate_limits_per_minute("gpt-4o-mini")
# 
# # Set parallel plan
# plan(multisession)
# 
# result_object <-
#   tabscreen_gpt(
#     data = test_dat, # RIS file data created above
#     prompt = prompt, # The prompt made above
#     studyid = studyid, # Name of variable containing study IDs
#     title = title, # Name of variable containing titles
#     abstract = abstract, # Name of variable containing abstracts
#     model = "gpt-4o-mini", # Model choice
#     reps = 10, # Using multiple screenings with the cheap gpt-4o-mini model
#     rpm = models_rpm$requests_per_minute # Requests per minutes retrieved from the above object
#   )
# #> * The approximate price of the current (simple) screening will be around $0.2237.
# #> Progress: ───────────────────────────────────────────────────────────────── 100%
# 
# # Back to the sequential plan
# plan(sequential)

## ----message=FALSE, eval=FALSE------------------------------------------------
# # The print output when calling the result object
# result_object
# #>
# #> Find the final result dataset via result_object$answer_data_aggregated
# 
# result_object$answer_data_aggregated |>
#   select(author, human_code, final_decision_gpt, final_decision_gpt_num)
# #> # A tibble: 200 × 4
# #>   author                                       human_code final_decision_gpt final_decision_gpt_num
# #>   <chr>                                             <dbl> <chr>                               <dbl>
# #> 1 Lara Elvira and Mart<c3><ad>n-Mar<c3><ad>a …          0 Exclude                                 0
# #> 2 Matsumoto Manabu                                      0 Exclude                                 0
# #> 3 Jordan Ann                                            0 Exclude                                 0
# #> 4 Antonova E and Hamid A and Wright B and Kum…          0 Exclude                                 0
# #> 5 Iafusco Dario                                         0 Exclude                                 0
# #> 6 Farrell L J and Barrett P M and Claassens S           0 Include                                 1
# #> 7 Rasalingam G and Rajalingam A and Chandrada…          0 Exclude                                 0
# #> 8 Chappel J N and DuPont R L                            0 Exclude                                 0
# #> 9 Waldrop Deborah P                                     0 Exclude                                 0
# #>10 Ioana-Eva C<c4><83>dariu and Rad Dana                 0 Exclude                                 0
# #># ℹ 190 more rows
# #># ℹ Use `print(n = ...)` to see more rows

## ----eval=FALSE---------------------------------------------------------------
# result_object <-
#   result_object |>
#   screen_errors()

## ----screen_stats-------------------------------------------------------------
# screen_performance <-
#   result_object |>
#   screen_analyzer(human_decision = human_code) # state the name of the variable containing the human decision.
# 
# screen_performance
# #> # A tibble: 1 × 9
# #>   promptid model        reps top_p p_agreement recall specificity incl_p criteria
# #>      <int> <chr>       <int> <dbl>       <dbl>  <dbl>       <dbl>  <dbl> <chr>
# #>1        1 gpt-4o-mini    10     1        0.97   0.92       0.987    0.4 Studies have been included in at least 40% of the 10 screenings.

## ----eval=TRUE, echo=FALSE, fig.cap='*Figure 5 - Generic benchmark scheme from Vembye et al. (2024)*'----
knitr::include_graphics("helper-stuff/benchmark_scheme.png")

## -----------------------------------------------------------------------------
# incl_dist <- attr(screen_performance, "p_incl_data")
# incl_dist |> select(model, recall, specificity, criteria)
# #> # A tibble: 10 × 4
# #>   model       recall specificity criteria
# #>   <chr>        <dbl>       <dbl> <chr>
# #> 1 gpt-4o-mini   0.96       0.987 Studies have been included in at least 10% of the 10 screenings.
# #> 2 gpt-4o-mini   0.96       0.987 Studies have been included in at least 20% of the 10 screenings.
# #> 3 gpt-4o-mini   0.94       0.987 Studies have been included in at least 30% of the 10 screenings.
# #> 4 gpt-4o-mini   0.92       0.987 Studies have been included in at least 40% of the 10 screenings.
# #> 5 gpt-4o-mini   0.92       0.987 Studies have been included in at least 50% of the 10 screenings.
# #> 6 gpt-4o-mini   0.92       0.987 Studies have been included in at least 60% of the 10 screenings.
# #> 7 gpt-4o-mini   0.92       0.987 Studies have been included in at least 70% of the 10 screenings.
# #> 8 gpt-4o-mini   0.88       0.987 Studies have been included in at least 80% of the 10 screenings.
# #> 9 gpt-4o-mini   0.84       0.987 Studies have been included in at least 90% of the 10 screenings.
# #>10 gpt-4o-mini   0.74       0.987 Studies have been included in all of the 10 screenings.

## -----------------------------------------------------------------------------
# disagree_dat <-
#   result_object$answer_data_aggregated |>
#   filter(human_code == 1, final_decision_gpt_num == 0, incl_p == 0)
# 
# plan(multisession)
# 
# result_object_detail <-
#   tabscreen_gpt(
#     data = disagree_dat,
#     prompt = prompt,
#     studyid = studyid,
#     title = title,
#     abstract = abstract,
#     model = "gpt-4o-mini",
#     rpm = models_rpm$requests_per_minute,
#     decision_description = TRUE # Get detailed screening decisions
#   )
# #> * The approximate price of the current (simple) screening will be around $0.0002.
# #> * Be aware that getting descriptive, detailed responses will substantially
# #> increase the prize of the screening relative to the noted approximate prize.
# #> Progress: ───────────────────────────────────────────────────────────────── 100%
# 
# plan(sequential)

## -----------------------------------------------------------------------------
# # Example of abstract included by the human and excluded by gpt-4o-mini
# result_object_detail$answer_data$abstract[1]
# #> [1] "Introduction: Many universal school-based preventative intervention trials
# #> for anxiety have been conducted in Western countries. This pilot study examined
# #> the efficacy and acceptability of a school-based, universal preventative program
# #> for anxiety among children aged 8<e2><80><93>9 years in Japan. The program was
# #> based on cognitive-behavioral therapy (CBT) and was informed by similar universal
# #> programs (i.e., the Fun FRIENDS program; Barrett, 2007a, 2007b). Methods: Seventy-four
# #> children from a single school were allocated to an intervention or control group.
# #> The intervention comprised 10 CBT sessions, and assessments were conducted before
# #> and after the program. The primary outcome measure was the Spence Children's Anxiety Scale (SCAS)
# #> as children's self-report. Secondary outcome measures were the Depression Self-Rating
# #> Scale for Children (DSRS-C), Children's Hope Scale (Hope),
# #> Spence Children's Anxiety Scale-Parent Version (SCAS-P), and Strengths
# #> and Difficulties Questionnaire-Parent Version (SDQ-P). Results:  The SCAS as the
# #> primary outcome showed no significant differences between the two groups.
# #> In addition, DSRS-C, Hope and SDQ-P also showed no significant differences.
# #> SCAS-P in the intervention group showed significant decrease compared to those
# #> in the control group. Conclusion: The results of this trial study suggest that
# #> a school-based universal preventative  program for anxiety may have no significant
# #> effects on 8<e2><80><93>9-year-old children.
# #> (PsycInfo Database Record (c) 2022 APA, all rights reserved)"

## -----------------------------------------------------------------------------
# # Example of explanation for exclusion
# # Seems reasonable why the records was thrown out by gpt.
# result_object_detail$answer_data$detailed_description[1]
# #> [1] "The study does not focus on the FRIENDS preventive programme; instead,
# #> it evaluates a different school-based CBT intervention and references
# #> the Fun FRIENDS program without investigating its effects directly.
# #> Additionally, it assesses a general anxiety intervention rather than
# #> specifically measuring the FRIENDS programme's effectiveness."

## ----eval = FALSE-------------------------------------------------------------
# # All RIS file data
# all_dat <-
#   bind_rows(ris_dat_excl, ris_dat_incl) |> # Use RIS file data here
#   filter(!is.na(abstract)) |> # Only screen studies with an abstract
#   mutate(studyid = 1:n())
# 
# app_obj <-
#   approximate_price_gpt(
#     data = all_dat,
#     prompt = prompt,
#     studyid = studyid,
#     title = title,
#     abstract = abstract,
#     model = c("gpt-4o-mini", "gpt-4"), # To compare model prizes
#     reps = c(10, 1)
#   )
# 
# app_obj
# #> The approximate price of the (simple) screening will be around $64.1443.
# 
# app_obj$price_dollar
# #> [1] 64.1443
# app_obj$price_data
# #> # A tibble: 2 × 6
# #>   prompt   model       iterations input_price_dollar output_price_dollar total_price_dollar
# #>   <chr>    <chr>            <dbl>              <dbl>               <dbl>              <dbl>
# #> 1 Prompt 1 gpt-4o-mini         10               2.99               0.111               3.11
# #> 2 Prompt 1 gpt-4                1              59.9                1.11               61.0

## -----------------------------------------------------------------------------
# # Set parallel plan
# plan(multisession)
# 
# 
# # NOT RUN
# result_object <-
#   tabscreen_gpt(
#     data = all_dat, # RIS file data created above
#     prompt = prompt, # The prompt made above
#     studyid = studyid, # Name of variable containing study IDs
#     title = title, # Name of variable containing titles
#     abstract = abstract, # Name of variable containing abstracts
#     model = "gpt-4o-mini", # Model choice
#     reps = 10, # Using multiple screenings with the cheap gpt-4o-mini model
#     rpm = models_rpm$requests_per_minute # Requests per minutes retrieved from the above object
#   )
# #> * The approximate price of the current (simple) screening will be around $0.2237.
# #> Progress: ───────────────────────────────────────────────────────────────── 100%
# 
# # Back to the sequential plan
# plan(sequential)

## -----------------------------------------------------------------------------
# incl_refs <- result_object$answer_data_aggregated |>
#   filter(incl_p >= 0.1)
# 
# 
# write_refs(as.data.frame(incl_refs), file = "file_name.ris", format = "ris")

