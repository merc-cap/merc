import { Link } from "@mui/material";
import OpenInNewIcon from "@mui/icons-material/OpenInNew";

interface Props {
  href: string;
  title?: string;
  children?: React.ReactNode;
}

const ExternalLink = ({ href, title, children }: Props) => {
  return (
    <Link href={href} title={title} target="_blank">
      {children} <OpenInNewIcon sx={{ fontSize: 14 }} />
    </Link>
  );
};

export default ExternalLink;
