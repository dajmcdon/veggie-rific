# veggie-rific

Evaluation materials for Flu/Covid hospitalizations

---

### Procedure to produce local reports

Covid:
1. Clone the repo.
2. Copy the `rmd-files/hospitalization_template.Rmd` and rename to `rmd-files/covid-yyyy-mm-dd.Rmd`
3. Edit as needed (perhaps only to point to the right results file in the AWS bucket).
4. Knit.
5. Add a descriptive link in `index.md`.
6. Commit (only the `.Rmd`, `.html`, and `index.md`) and push.

Flu:
TBD
