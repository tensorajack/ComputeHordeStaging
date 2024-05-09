import abc

from compute_horde.mv_protocol.miner_requests import V0JobFinishedRequest


class AbstractSyntheticJobGenerator(abc.ABC):
    @abc.abstractmethod
    def timeout_seconds(self) -> int:
        ...

    @abc.abstractmethod
    def base_docker_image_name(self) -> str:
        ...

    @abc.abstractmethod
    def docker_image_name(self) -> str:
        ...

    @abc.abstractmethod
    def docker_run_options_preset(self) -> str:
        ...

    def docker_run_cmd(self) -> list[str] | None:
        return None

    def raw_script(self) -> str | None:
        return None

    @abc.abstractmethod
    def volume_contents(self) -> str:
        ...

    @abc.abstractmethod
    def verify(self, msg: V0JobFinishedRequest, time_took: float) -> tuple[bool, str, float]:
        ...

    @abc.abstractmethod
    def job_description(self) -> str:
        ...
