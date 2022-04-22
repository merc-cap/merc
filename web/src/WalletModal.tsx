import { useConnect } from "wagmi";
import * as React from "react";
import clsx from "clsx";
import { Box, styled, Theme } from "@mui/system";
import ModalUnstyled from "@mui/base/ModalUnstyled";
import Fade from "@mui/material/Fade";
import { Button, Card, Stack, Typography } from "@mui/material";

const BackdropUnstyled = React.forwardRef<
  HTMLDivElement,
  { open?: boolean; className: string }
>((props, ref) => {
  const { open, className, ...other } = props;
  return (
    <div
      className={clsx({ "MuiBackdrop-open": open }, className)}
      ref={ref}
      {...other}
    />
  );
});

const Modal = styled(ModalUnstyled)`
  position: fixed;
  z-index: 1300;
  right: 0;
  bottom: 0;
  top: 0;
  left: 0;
  display: flex;
  align-items: center;
  justify-content: center;
`;

const Backdrop = styled(BackdropUnstyled)`
  z-index: -1;
  position: fixed;
  right: 0;
  bottom: 0;
  top: 0;
  left: 0;
  background-color: rgba(0, 0, 0, 0.5);
  -webkit-tap-highlight-color: transparent;
`;

interface Props {
  open: boolean;
  handleClose: () => void;
}

export const WalletModal = ({ open, handleClose }: Props) => {
  const [{ data, error }, connect] = useConnect();

  return (
    <Modal
      aria-labelledby="transition-modal-title"
      aria-describedby="transition-modal-description"
      open={open}
      onClose={handleClose}
      closeAfterTransition
      BackdropComponent={Backdrop}
    >
      <Fade in={open} timeout={300}>
        <Box>
          <Card>
            <Box sx={{ p: 4 }}>
              <Stack spacing={2}>
                {data.connectors.map((connector) => (
                  <Button
                    disabled={!connector.ready}
                    key={connector.id}
                    variant="outlined"
                    onClick={() => connect(connector)}
                  >
                    {connector.name}
                    {!connector.ready && " (unsupported)"}
                  </Button>
                ))}

                {error && (
                  <Typography variant="caption">
                    {error?.message ?? "Failed to connect"}
                  </Typography>
                )}
              </Stack>
            </Box>
          </Card>
        </Box>
      </Fade>
    </Modal>
  );
};
