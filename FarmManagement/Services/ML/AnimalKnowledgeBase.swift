import Foundation

enum AnimalKnowledgeBase {
    static func lookup(_ label: String) -> DiseaseInfo {
        let key = label.lowercased()

        if key.contains("lumpy") || key.contains("skin nodule") {
            return DiseaseInfo(
                name: "Lumpy Skin Disease",
                symptoms: [
                    "Firm, raised nodules (2-5cm) on skin, especially head and neck",
                    "Fever, nasal discharge, and drooling",
                    "Swollen lymph nodes and reduced milk production",
                    "Reluctance to move, weight loss"
                ],
                remediations: [
                    "Isolate affected animals immediately to prevent spread",
                    "Vaccinate healthy herd with LSD vaccine (Neethling strain)",
                    "Apply wound spray/antiseptic to open nodules",
                    "Control flies and ticks — they are primary vectors",
                    "Provide supportive care: anti-inflammatories, fluids, shade",
                    "Report to local veterinary authority — notifiable disease"
                ]
            )
        }

        if key.contains("foot") && key.contains("mouth") || key.contains("fmd") {
            return DiseaseInfo(
                name: "Foot-and-Mouth Disease",
                symptoms: [
                    "Blisters/vesicles on tongue, gums, and lips",
                    "Lesions between hooves causing severe lameness",
                    "Excessive drooling and smacking of lips",
                    "High fever (40-41°C), refusal to eat"
                ],
                remediations: [
                    "IMMEDIATELY quarantine affected animals",
                    "Report to state veterinarian — legally notifiable",
                    "Do NOT move any animals or equipment off the farm",
                    "Disinfect all footwear and equipment with citric acid",
                    "Vaccinate surrounding herds as directed by authorities",
                    "Provide soft feed and clean water to affected animals"
                ]
            )
        }

        if key.contains("mastitis") || key.contains("udder") {
            return DiseaseInfo(
                name: "Mastitis",
                symptoms: [
                    "Swollen, hot, and painful udder quarters",
                    "Abnormal milk: clots, watery, discoloured",
                    "Reduced milk yield",
                    "Fever and loss of appetite in severe cases"
                ],
                remediations: [
                    "Milk out the affected quarter frequently (strip milking)",
                    "Administer intramammary antibiotic tubes as prescribed by vet",
                    "Apply cold compresses to reduce swelling",
                    "Improve milking hygiene — teat dipping before and after",
                    "Ensure clean, dry bedding in housing areas",
                    "Cull chronically infected animals to protect the herd"
                ]
            )
        }

        if key.contains("bloat") || key.contains("swollen abdomen") {
            return DiseaseInfo(
                name: "Bloat (Ruminal Tympany)",
                symptoms: [
                    "Distended left flank (visibly swollen abdomen)",
                    "Difficulty breathing, mouth breathing",
                    "Restlessness, kicking at belly",
                    "Sudden death in severe cases"
                ],
                remediations: [
                    "EMERGENCY: Pass a stomach tube to release gas",
                    "Administer anti-bloat drench (poloxalene or vegetable oil)",
                    "Walk the animal gently to encourage gas release",
                    "In critical cases, trocar puncture of rumen (vet only)",
                    "Prevention: feed dry hay before lush pasture access",
                    "Add bloat guard blocks to pasture feeding areas"
                ]
            )
        }

        if key.contains("wound") || key.contains("laceration") || key.contains("injury") {
            return DiseaseInfo(
                name: "Open Wound / Laceration",
                symptoms: [
                    "Visible cut, tear, or puncture in skin",
                    "Bleeding or oozing from wound site",
                    "Swelling and redness around the area",
                    "Animal favouring or protecting the injured area"
                ],
                remediations: [
                    "Clean wound thoroughly with saline or dilute iodine",
                    "Apply antiseptic wound spray (purple spray / blue spray)",
                    "Keep wound dry and protected from flies",
                    "Administer tetanus antitoxin if not vaccinated",
                    "Monitor for signs of infection (pus, heat, swelling)",
                    "Consult vet for deep wounds that may need suturing"
                ]
            )
        }

        if key.contains("limp") || key.contains("lame") || key.contains("hoof") {
            return DiseaseInfo(
                name: "Lameness / Hoof Problem",
                symptoms: [
                    "Favouring one or more legs while walking",
                    "Swelling around the hoof or joint",
                    "Reluctance to stand or walk",
                    "Foul smell from hoof area (possible foot rot)"
                ],
                remediations: [
                    "Examine hoof for stones, abscesses, or rot",
                    "Trim overgrown hooves and clean between claws",
                    "Apply copper sulfate foot bath (5% solution)",
                    "Administer anti-inflammatory (flunixin — vet prescribed)",
                    "Provide soft bedding and limit walking on hard surfaces",
                    "For foot rot: topical oxytetracycline spray + systemic antibiotics"
                ]
            )
        }

        if key.contains("eye") || key.contains("pink") || key.contains("conjunctiv") {
            return DiseaseInfo(
                name: "Pinkeye (Infectious Keratoconjunctivitis)",
                symptoms: [
                    "Excessive tearing and watery eye discharge",
                    "Cloudy or white spot on the cornea",
                    "Squinting or keeping the eye closed",
                    "Swollen eyelids, sensitivity to light"
                ],
                remediations: [
                    "Apply ophthalmic antibiotic ointment (oxytetracycline) twice daily",
                    "Provide shade — UV light worsens the condition",
                    "Isolate affected animals to reduce fly-borne spread",
                    "Use fly control measures (ear tags, pour-on)",
                    "In severe cases, vet may inject antibiotic under the eyelid",
                    "Patch the eye to protect from dust and sunlight"
                ]
            )
        }

        if key.contains("tick") || key.contains("parasite") || key.contains("mange") {
            return DiseaseInfo(
                name: "External Parasites (Ticks/Mange)",
                symptoms: [
                    "Visible ticks attached to skin, especially ears and underbelly",
                    "Hair loss in patches, crusty or scabby skin",
                    "Excessive scratching, rubbing against objects",
                    "Poor coat condition, weight loss"
                ],
                remediations: [
                    "Apply pour-on acaricide (e.g. amitraz or ivermectin)",
                    "Dip animals in approved tick dip at regular intervals",
                    "Rotate dip chemicals to prevent resistance",
                    "Keep pastures short — ticks thrive in tall grass",
                    "Treat housing areas with residual insecticide",
                    "For mange: injectable ivermectin (vet prescribed), repeat in 14 days"
                ]
            )
        }

        if key.contains("respiratory") || key.contains("cough") || key.contains("pneumonia") {
            return DiseaseInfo(
                name: "Respiratory Infection / Pneumonia",
                symptoms: [
                    "Persistent coughing, laboured breathing",
                    "Nasal discharge (clear to thick yellow/green)",
                    "High fever, depression, off feed",
                    "Rapid shallow breathing, head extended forward"
                ],
                remediations: [
                    "Isolate sick animals in a well-ventilated, dry area",
                    "Administer long-acting antibiotic (oxytetracycline LA or tulathromycin)",
                    "Provide anti-inflammatory for fever and pain",
                    "Ensure adequate ventilation in housing — ammonia buildup worsens it",
                    "Vaccinate herd against common respiratory pathogens",
                    "Reduce stress: avoid overcrowding, transport, and mixing groups"
                ]
            )
        }

        if key.contains("diarrh") || key.contains("scour") {
            return DiseaseInfo(
                name: "Diarrhoea / Scours",
                symptoms: [
                    "Watery or bloody faeces",
                    "Dehydration: sunken eyes, dry nose, skin tenting",
                    "Weakness, reluctance to stand (especially calves)",
                    "Soiled hindquarters and tail"
                ],
                remediations: [
                    "Rehydrate with oral electrolyte solution immediately",
                    "For calves: continue milk feeding alongside electrolytes",
                    "Identify cause: bacterial, viral, or parasitic (faecal test)",
                    "Administer appropriate treatment based on cause",
                    "Keep affected animals in clean, dry, warm environment",
                    "Deworm if parasitic cause suspected (fenbendazole or ivermectin)"
                ]
            )
        }

        if key.contains("healthy") || key.contains("normal") {
            return DiseaseInfo(
                name: "Animal Appears Healthy ✅",
                symptoms: [],
                remediations: []
            )
        }

        return DiseaseInfo(
            name: label,
            symptoms: ["Visual anomaly detected — requires closer examination"],
            remediations: [
                "Take additional photos from different angles",
                "Record the animal's temperature, appetite, and behaviour",
                "Consult your local veterinarian for proper diagnosis",
                "Isolate the animal as a precaution until assessed"
            ]
        )
    }
}
