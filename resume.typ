#import "utils.typ"

#let resume_data = json("resume.json")

#let resume_vars = (
    headingfont: "Libertinus Serif",
    bodyfont: "Libertinus Serif",
    fontsize: 11pt,          // https://typst.app/docs/reference/layout/length
    linespacing: 6pt,        // length
    sectionspacing: 0pt,     // length
    showAddress:  false,      // https://typst.app/docs/reference/foundations/bool
    showNumber: false,        // bool
    showTitle: true,         // bool
    headingsmallcaps: false, // bool
    sendnote: false,         // bool. set to false to have sideways endnote
)

// Set page layout
#let resume_init(doc) = {
    set text(
        font: resume_vars.bodyfont,
        size: resume_vars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: resume_vars.linespacing
    )

    set par(
        leading: resume_vars.linespacing,
        justify: true,
    )

    // Uppercase section headings
    show heading.where(
        level: 2,
    ): it => block(width: 100%)[
        #v(resume_vars.sectionspacing)
        #set align(left)
        #set text(font: resume_vars.headingfont, size: 1em, weight: "bold")
        #if (resume_vars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(-0.75em) #line(length: 100%, stroke: 1pt + black) // draw a line
    ]

    // Name title/heading
    show heading.where(
        level: 1,
    ): it => block(width: 100%)[
        #set text(font: resume_vars.headingfont, size: 1.5em, weight: "bold")
        #if (resume_vars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(2pt)
    ]

    // add custom document style rules here
    set page(                 // https://typst.app/docs/reference/layout/page
        paper: "us-letter",
        numbering: "1 / 1",
        number-align: center,
        margin: 1.25cm,
    )

    // set list(indent: 1em)

    doc
}

// Job titles
#let jobtitletext(info, resume_vars) = {
    if ("titles" in info.basics and info.basics.label != none) and resume_vars.showTitle {
        block(width: 100%)[
            *#info.basics.label*
            #v(-4pt)
        ]
    } else {none}
}

// Address
#let addresstext(info, resume_vars) = {
    if ("location" in info.basics and info.basics.location != none) and resume_vars.showAddress {
        // Filter out empty address fields
        let address = info.basics.location.pairs().filter(it => it.at(1) != none and str(it.at(1)) != "")
        // Join non-empty address fields with commas
        let location = address.map(it => str(it.at(1))).join(", ")

        block(width: 100%)[
            #location
            #v(-4pt)
        ]
    } else {none}
}

#let contacttext(info, resume_vars) = block(width: 100%)[
    #let profiles = (
        if "email" in info.basics and info.basics.email != none { box(link("mailto:" + info.basics.email)) },
        if ("phone" in info.basics and info.basics.phone != none) and resume_vars.showNumber {box(link("tel:" + info.basics.phone))} else {none},
        if ("url" in info.basics) and (info.basics.url != none) {
            box(link(info.basics.url)[#info.basics.url.split("//").at(1)])
        }
    ).filter(it => it != none) // Filter out none elements from the profile array

    #if ("profiles" in info.basics) and (info.basics.profiles.len() > 0) {
        for profile in info.basics.profiles {
            profiles.push(
                box(link(profile.url)[#profile.url.split("//").at(1)])
            )
        }
    }

    #set text(font: resume_vars.bodyfont, weight: "medium", size: resume_vars.fontsize * 1)
    #pad(x: 0em)[
        #profiles.join([#" " #sym.bar #" "])
    ]
]

#let resume_heading(info, resume_vars) = {
    align(center)[
        = #info.basics.name
        #jobtitletext(info, resume_vars)
        #addresstext(info, resume_vars)
        #contacttext(info, resume_vars)
    ]
}

#let skills(info, title: "Skills", isbreakable: true) = {
    if (("languages" in info and info.languages != none) or ("skills" in info and info.skills != none) or ("interests" in info and info.interests != none)) {block(breakable: isbreakable)[
        == #title
        #if ("languages" in info) and (info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Languages*: #langs.join(", ")
        ]
        #if ("skills" in info) and (info.skills != none) [
            #for group in info.skills [
                - *#group.name*: #group.keywords.join(", ")
            ]
        ]
        #if ("interests" in info) and (info.interests != none) [
            #for group in info.interests [
                - *#group.name*: #group.keywords.join(", ")
            ]
        ]
    ]}
}

#let experience(info, title: "Experience", isbreakable: true) = {
    if ("work" in info) and (info.work != none) {block[
        == #title
        #for w in info.work {
            block(width: 100%, breakable: isbreakable)[
                // Parse ISO date strings into datetime objects
                #let start = utils.strpdate(w.startDate)
                #let end
                #if ("endDate" in w) and (w.endDate != none) {
                    end = utils.strpdate(w.endDate)
                } else {
                    end = utils.strpdate("present")
                }
                
                #if ("url" in w) and (w.url != none) [
                    *#w.position*, #link(w.url)[#w.name] -- #w.location #h(1fr) #utils.daterange(start, end)
                ] else [
                    *#w.position*, #w.name -- #w.location #h(1fr) #utils.daterange(start, end)
                ]
            ]
            block(width: 100%, breakable: isbreakable, above: 0.6em)[
                // Highlights or Description
                #if ("highlights" in w) and (w.highlights != none) {
                    for hi in w.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]}
}

// each section body can be overridden by re-declaring it here
// #let cveducation = []

// ========================================================================== //

#show: doc => resume_init(doc)

#resume_heading(resume_data, resume_vars)
#skills(resume_data)
#experience(resume_data)
// #cvwork(cvdata)
// #cveducation(cvdata)
// #cvaffiliations(cvdata)
// #cvprojects(cvdata)
// #cvawards(cvdata)
// #cvcertificates(cvdata)
// #cvpublications(cvdata)
// #cvskills(cvdata)
// #cvreferences(cvdata)
// #endnote(resume_vars)
