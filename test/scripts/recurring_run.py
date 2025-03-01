import time
import os
from kfp import Client

# Kubeflow Pipelines API URL
KFP_ENDPOINT = os.environ['KFP_ENDPOINT']
KFP_CLIENT = Client(host=KFP_ENDPOINT)

# Pipeline and Experiment Details
EXPERIMENT_NAME = "scheduled-test-experiment"
PIPELINE_NAME = "hello-world"
NAMESPACE = "kubeflow"  

def create_experiment():
    """Creates an experiment if it doesn't exist."""
    experiment = KFP_CLIENT.create_experiment(name=EXPERIMENT_NAME, namespace=NAMESPACE)
    return experiment.id

def get_pipeline_id():
    """Fetches the pipeline ID by name."""
    pipelines = KFP_CLIENT.list_pipelines().pipelines
    for pipeline in pipelines:
        if pipeline.name == PIPELINE_NAME:
            return pipeline.id
    raise Exception(f"Pipeline '{PIPELINE_NAME}' not found.")

def schedule_pipeline():
    """Schedules the pipeline to run every minute."""
    experiment_id = create_experiment()
    pipeline_id = get_pipeline_id()

    trigger = {
        "start_time": None,
        "end_time": None,
        "cron_schedule": "*/1 * * * *",  # Every minute
        "enabled": True
    }

    run_name = f"{PIPELINE_NAME}-schedule"
    response = KFP_CLIENT.create_recurring_run(
        experiment_id=experiment_id,
        job_name=run_name,
        pipeline_id=pipeline_id,
        start_time=trigger.get("start_time"),
        end_time=trigger.get("end_time"),
        cron_expression=trigger.get("cron_schedule"),
        enabled=trigger.get("enabled")
    )
    print(f"Scheduled pipeline: {response.id}")
    return response.id

def get_successful_runs():
    """Fetches successful runs for the experiment."""
    experiment_id = create_experiment()
    runs = KFP_CLIENT.list_runs(experiment_id=experiment_id).runs
    successful_runs = [run for run in runs if run.status == "Succeeded"]
    return successful_runs

def wait_and_verify():
    """Waits for 4 minutes and checks if at least 2 runs succeeded."""
    print("Waiting for scheduled runs to execute...")
    time.sleep(240)  # Wait for 4 minutes

    successful_runs = get_successful_runs()
    assert len(successful_runs) >= 2, f"Expected at least 2 successful runs, but got {len(successful_runs)}"
    print("Test passed: At least 2 runs succeeded.")

if __name__ == "__main__":
    schedule_pipeline()
    wait_and_verify()
