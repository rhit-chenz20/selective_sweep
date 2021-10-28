
configfile: '03_config.yaml'
report: 'captions/inference.rst'

# Think about how this interacts with the cluster, but do it later.
# workdir: config["workdir"]
# Cluster rules might have shadow: copy-minimal.

rule all:
    input:
        training_data_distributions = expand(
            "output/training-data/info/{sim_id}_training-distributions.txt",
            sim_id=config["training_ids"]
        ),
        testing_inferences = expand(
            "output/inferences-testing/{target}_{training}_{testing}.tsv",
            target=config["inference_targets"],
            training=config["training_ids"],
            testing=config["testing_ids"]
        ),
        training_inferences = expand(
            "output/inferences-training/{target}_{training}_{testing}.tsv",
            target=config["inference_targets"],
            training=config["training_ids"],
            testing=["training", "validation"]
        ),
        empirical_inferences = expand(
            "output/inferences-empirical/{target}_{training}_empirical.tsv",
            target=config["inference_targets"],
            training=config["training_ids"]
        ),
        overfitting_reports = expand(
            "output/model-fitting/{target}_{training}_overfitting.tsv",
            target=config["inference_targets"],
            training=config["training_ids"]
        )


rule apply_model_to_empirical_data:
    input: "output/trained-models/{target}_{training}.pth"
    output: "output/inferences-empirical/{target}_{training}_empirical.tsv"
    shell:
        "touch {output};"


rule apply_model_to_testing_data:
    input:
        fit_model = "output/trained-models/{target}_{training}.pth",
        data = "output/simulation-data/{testing}/data.tar",
        logdata  = "output/simulation-data/{testing}/logdata.tar"
    output: "output/inferences-testing/{target}_{training}_{testing}.tsv",
    shell:
        "touch {output};"

rule aggregate_overfitting_replicates:
    input:
        expand(
            "output/model-fitting/{{target}}_{{training}}_replicate-{k}.tsv",
            k=range(config["num_overfitting_replicates"])
        )
    output:
        aggregated = "output/model-fitting/{target}_{training}_overfitting.tsv"
    conda: "envs/simulate.yaml"
    script: "scripts/inference/aggregate-overfitting-replicates.py"


rule fit_model:
    input:
        training = "output/training-data/balanced/{target}_{training}_training.tsv",
        validation = "output/training-data/balanced/{target}_{training}_validation.tsv",
        data = "output/simulation-data/{training}/data.tar",
        logdata  = "output/simulation-data/{training}/logdata.tar"
    output:
        fit_model = "output/trained-models/{target}_{training}.pth",
        training_inferences = "output/inferences-training/{target}_{training}_training.tsv",
        validation_inferences = "output/inferences-training/{target}_{training}_validation.tsv",
        fit_report = "output/model-fitting/{target}_{training}_fit.tsv"
    params:
        save_model = True,
        save_inferences = True,
        use_log_data = False
    conda: "envs/ml.yaml"
    notebook: "notebooks/inference/fit-neural-network.py.ipynb"


rule overfitting_simple_fit:
    input:
        training = "output/training-data/balanced/{target}_{training}_training.tsv",
        validation = "output/training-data/balanced/{target}_{training}_validation.tsv",
        data = "output/simulation-data/{training}/data.tar",
        logdata  = "output/simulation-data/{training}/logdata.tar"
    output:
        fit_report = "output/model-fitting/{target}_{training}_replicate-{k}.tsv"
    params:
        save_model = False,
        save_inferences = False,
        use_log_data = False
    conda: "envs/ml.yaml"
    notebook: "notebooks/inference/fit-neural-network.py.ipynb"


rule balance_training_data:
    input:
        training = "output/training-data/train-valid-split/{training}_training.tsv",
        validation = "output/training-data/train-valid-split/{training}_validation.tsv"
    output:
        balanced_training = "output/training-data/balanced/{target}_{training}_training.tsv",
        balanced_validation = "output/training-data/balanced/{target}_{training}_validation.tsv"
    conda: "envs/simulate.yaml"
    script: "scripts/inference/balance-training-data.py"

    
rule train_validation_split:
    input:
        sim_params = "output/simulation-data/{training}/parameters.tsv"
    output:
        training = "output/training-data/train-valid-split/{training}_training.tsv",
        validation = "output/training-data/train-valid-split/{training}_validation.tsv"
    params:
        random_seed = 13
    conda: "envs/ml.yaml"
    notebook: "notebooks/inference/train-validation-split.py.ipynb"


rule check_training_distributions:
    input: "output/simulation-data/{sim_id}/parameters.tsv"
    output: "output/training-data/info/{sim_id}_training-distributions.txt"
    conda: "envs/simulate.yaml"
    notebook: "notebooks/inference/check-training-distributions.py.ipynb"


rule combine_simulation_tasks:
    output:
        data = "output/simulation-data/{sim}/data.tar",
        parameters = "output/simulation-data/{sim}/parameters.tsv",
        info = "output/simulation-data/{sim}/info.txt",
        features = "output/simulation-data/{sim}/features.tar.gz",
        logdata  = "output/simulation-data/{sim}/logdata.tar"
    conda: "envs/simulate.yaml"
    notebook: "notebooks/inference/combine-simulations.py.ipynb"
